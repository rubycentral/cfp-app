class User < ApplicationRecord
  normalizes :email, with: ->(e) { e.strip.downcase }

  has_secure_password

  PASSWORD_LENGTH = 6..128

  generates_token_for :email_confirmation, expires_in: 3.days do
    unconfirmed_email || email
  end

  before_update :postpone_email_change, if: :postpone_email_change?
  # Distinct method names are load-bearing: after_*_commit callbacks share
  # one :commit chain deduped by [kind, filter], so two declarations with
  # the same symbol silently merge and drop the first one's conditions.
  after_create_commit :send_creation_confirmation_instructions, if: -> { !confirmed? && email.present? }
  after_update_commit :send_reconfirmation_instructions, if: -> { saved_change_to_unconfirmed_email? && unconfirmed_email.present? }

  # Map password_digest to encrypted_password for has_secure_password compatibility.
  # undef_method :password_digest used to precede this (removing Devise
  # database_authenticatable's protected password_digest(password) hashing
  # method so this reader could take over); with the devise directive gone
  # in PR 2, that method is never defined and undef_method would raise.
  alias_attribute :password_digest, :encrypted_password
  def password_digest
    encrypted_password
  end

  has_many :sessions,     dependent: :destroy
  has_many :identities,   dependent: :destroy
  has_many :invitations,  dependent: :destroy
  has_many :teammates, dependent: :destroy
  has_many :reviewer_teammates, -> { where(role: [:reviewer, :program_team, :organizer]) }, class_name: 'Teammate'
  has_many :reviewer_events, through: :reviewer_teammates, source: :event
  has_many :organizer_teammates, -> { where(role: :organizer) }, class_name: 'Teammate'
  has_many :organizer_events, through: :organizer_teammates, source: :event
  has_many :speakers,      dependent: :destroy
  has_many :ratings,       dependent: :destroy
  has_many :comments,      dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :proposals, through: :speakers, source: :proposal
  has_many :program_sessions, through: :speakers, source: :program_session

  validates :bio, length: { maximum: 500 }
  validates :name, presence: true, allow_nil: true
  validates_uniqueness_of :email, allow_blank: true
  validates_format_of :email, with: /\A[^@\s]+@[^@\s]+\z/, allow_blank: true, if: :email_changed?  # equivalent to Devise.email_regexp
  validates_presence_of :email, on: :create, if: -> { provider.blank? && identities.blank? }
  validates_presence_of :email, on: :update, if: -> { provider.blank? || unconfirmed_email.blank? }
  validates_presence_of :password, on: :create
  validates_confirmation_of :password, on: :create
  validates_length_of :password, within: PASSWORD_LENGTH, allow_blank: true

  before_create :check_pending_invite_email

  accepts_nested_attributes_for :teammates

  attr_accessor :pending_invite_email

  def self.from_omniauth(auth, invitation_email = nil)
    # First, lookup in identities table
    identity = Identity.find_by(provider: auth.provider, uid: auth.uid)
    return identity.user if identity

    # Fall back to legacy lookup in users table
    if (user = find_by(provider: auth.provider, uid: auth.uid))
      # Migrate legacy user to identities table
      transaction do
        user.identities.create!(provider: auth.provider, uid: auth.uid, account_name: auth.account_name)
        user.update_columns(provider: nil, uid: nil)
      end
      return user
    end

    # Create new user with identity
    create_from_omniauth!(auth, invitation_email)
  end

  def self.create_from_omniauth!(auth, invitation_email = nil)
    user = new(
      name: auth['info']['name'],
      email: invitation_email || auth['info']['email'] || '',
      password: (password = SecureRandom.hex(10)),
      password_confirmation: password
    )
    user.identities.build(provider: auth.provider, uid: auth.uid, account_name: auth.account_name)

    if invitation_email.present? && (user.email == invitation_email)
      user.confirmed_at = Time.current
    end

    user.tap(&:save!)
  end

  def check_pending_invite_email
    if pending_invite_email.present? && pending_invite_email == email
      self.confirmed_at = Time.current
    end
  end

  # Hand-rolled replacements for Devise :confirmable (tokens are stateless
  # generates_token_for; the legacy confirmation_token column dies in PR 3).
  # Named email_confirmation_token until Task 2: Devise's confirmation_token
  # column reader must survive while Devise still owns the confirmations flow.
  def email_confirmation_token
    generate_token_for(:email_confirmation)
  end

  # The invitation specs and any lingering callers read confirmation_token;
  # the Devise column of that name stops being consulted as of PR 2 and is
  # dropped in PR 3.
  alias_method :confirmation_token, :email_confirmation_token

  def self.find_by_email_confirmation_token(token)
    find_by_token_for(:email_confirmation, token)
  end

  def confirmed?
    confirmed_at.present?
  end

  def confirm!
    # @bypass_confirmation_postpone silences Devise reconfirmable's own
    # postpone hook (active until Task 2 removes the devise directive;
    # the ivar becomes harmless dead weight then and leaves with PR 3).
    @bypass_confirmation_postpone = true
    @skip_email_change_postpone = true
    promoting_pending_email = unconfirmed_email.present?
    if promoting_pending_email
      self.email = unconfirmed_email
      self.unconfirmed_email = nil
    end
    self.confirmed_at ||= Time.current
    # Mirrors Devise confirmable: validate only when promoting a pending
    # email (uniqueness must hold); plain confirmation must succeed even for
    # users who fail validation (e.g. OAuth users with a blank email).
    save!(validate: promoting_pending_email)
  ensure
    @bypass_confirmation_postpone = @skip_email_change_postpone = nil
  end

  def send_confirmation_instructions
    ConfirmationsMailer.confirmation_instructions(self).deliver_later
  end

  # Devise confirmable equivalent: let an email change apply immediately on
  # the next save, bypassing the postpone-to-unconfirmed_email dance (used by
  # admin user edits, which should not require the admin's own reconfirmation).
  def skip_reconfirmation!
    @skip_email_change_postpone = true
  end

  def pending_invitations
    Invitation.pending.where(email: email)
  end

  def update_bio
    update(bio: speakers.last.bio) if bio.blank?
  end

  def gravatar_hash
    self.class.gravatar_hash(email)
  end

  def connected?(provider)
    identities.exists?(provider: provider) || (self.provider == provider)
  end

  def oauth_providers
    providers = identities.map(&:provider)
    providers << provider if provider.present?
    providers.uniq
  end

  def complete?
    name.present? && email.present? && unconfirmed_email.blank?
  end

  def organizer?
    organizer_events.exists?
  end

  def organizer_for_event?(event)
    #Checks for role of organizer through teammates
    teammates.organizer.for_event(event).exists?
  end

  def staff_for?(event)
    #Checks for any role in the event through teammates
    teammates.for_event(event).exists?
  end

  def reviewer?
    reviewer_events.exists?
  end

  def reviewer_for_event?(event)
    #Checks for role of reviewer through teammates
    teammates.reviewer.for_event(event).exists?
  end

  def program_team?
    teammates.program_team.exists?
  end

  def program_team_for_event?(event)
    teammates.program_team.for_event(event).exists?
  end

  def rating_for(proposal, build_new = true)
    rating = ratings.detect { |r| r.proposal_id == proposal.id }
    if rating
      rating
    elsif build_new
      ratings.build(proposal: proposal)
    end
  end

  def role_names
    self.teammates.collect {|p| p.role}.uniq.join(", ")
  end

  def assign_email
    if email.blank? && unconfirmed_email.present?
      unconfirmed_email
    else
      email
    end
  end

  def self.gravatar_hash(email)
    Digest::MD5.hexdigest(email.to_s.downcase)
  end

  def profile_errors
    profile_errors = ActiveModel::Errors.new(self)
    profile_errors.add(:name, :blank, message: "can't be blank") if name.blank?
    if unconfirmed_email.present?
      profile_errors.add(:email, :unconfirmed, message: "#{unconfirmed_email} needs confirmation")
    else
      profile_errors.add(:email, :blank, message: "can't be blank") if email.blank?
    end
    profile_errors
  end

  # Merge another user's associations into this user
  def merge_from!(other_user)
    transaction do
      other_user.invitations.update_all(user_id: id)
      other_user.teammates.update_all(user_id: id)
      other_user.speakers.update_all(user_id: id)
      other_user.ratings.update_all(user_id: id)
      other_user.comments.update_all(user_id: id)
      other_user.notifications.update_all(user_id: id)
      other_user.sessions.destroy_all

      # Clear legacy OAuth fields so the old user can't be found via from_omniauth
      other_user.update_columns(provider: nil, uid: nil)
    end
  end

  private

  def send_creation_confirmation_instructions
    send_confirmation_instructions
  end

  def send_reconfirmation_instructions
    send_confirmation_instructions
  end

  # Devise reconfirmable equivalent: a confirmed user's email change is
  # written to unconfirmed_email and applied by confirm! instead.
  def postpone_email_change?
    will_save_change_to_email? && confirmed? && email_in_database.present? && !@skip_email_change_postpone
  end

  def postpone_email_change
    self.unconfirmed_email = email
    self.email = email_in_database
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  name                   :string
#  email                  :string           default(""), not null
#  bio                    :text
#  admin                  :boolean          default(FALSE)
#  provider               :string
#  uid                    :string
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  remember_created_at    :datetime
#  created_at             :datetime
#  updated_at             :datetime
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token)
#  index_users_on_email                 (email)
#  index_users_on_reset_password_token  (reset_password_token)
#  index_users_on_uid                   (uid)
#
