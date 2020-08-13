require 'digest/md5'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :confirmable, #:validatable,
         :omniauthable, omniauth_providers: [:twitter, :github, :google_oauth2]

  has_many :invitations,  dependent: :destroy
  has_many :teammates, dependent: :destroy
  has_many :reviewer_teammates, -> { where(role: ['reviewer', 'program team', 'organizer']) }, class_name: 'Teammate'
  has_many :reviewer_events, through: :reviewer_teammates, source: :event
  has_many :organizer_teammates, -> { where(role: 'organizer') }, class_name: 'Teammate'
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
  validates_format_of :email, with: Devise.email_regexp, allow_blank: true, if: :email_changed?
  validates_presence_of :email, on: :create, if: -> { provider.blank? }
  validates_presence_of :email, on: :update, if: -> { provider.blank? || unconfirmed_email.blank? }
  validates_presence_of :password, on: :create
  validates_confirmation_of :password, on: :create
  validates_length_of :password, within: Devise.password_length, allow_blank: true

  before_create :check_pending_invite_email

  accepts_nested_attributes_for :teammates

  attr_accessor :pending_invite_email

  def self.from_omniauth(auth, invitation_email=nil)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      password = Devise.friendly_token[0,20]
      user.name = auth['info']['name'] if user.name.blank?
      user.email = invitation_email || auth['info']['email'] || '' if user.email.blank?
      user.password = password
      user.password_confirmation = password
      if !user.confirmed? && invitation_email.present? && user.email == invitation_email
        user.skip_confirmation!
      end
    end
  end

  def check_pending_invite_email
    if pending_invite_email.present? && pending_invite_email == email
      skip_confirmation!
    end
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
    self.provider == provider
  end

  def complete?
    name.present? && email.present? && unconfirmed_email.blank?
  end

  def organizer?
    organizer_events.count > 0
  end

  def organizer_for_event?(event)
    #Checks for role of organizer through teammates
    teammates.organizer.for_event(event).size > 0
  end

  def staff_for?(event)
    #Checks for any role in the event through teammates
    teammates.for_event(event).size > 0
  end

  def reviewer?
    reviewer_events.count > 0
  end

  def reviewer_for_event?(event)
    #Checks for role of reviewer through teammates
    teammates.reviewer.for_event(event).size > 0
  end

  def program_team?
    teammates.program_team.size > 0
  end

  def program_team_for_event?(event)
    teammates.program_team.for_event(event).size > 0
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
end

# == Schema Information
#
# Table name: users
#
#  id                     :bigint(8)        not null, primary key
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
