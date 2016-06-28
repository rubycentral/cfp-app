require 'digest/md5'

class User < ActiveRecord::Base
  STAFF_ROLES = ['reviewer', 'program team', 'organizer']
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :confirmable, #:validatable,
         :omniauthable, omniauth_providers: [:twitter, :github]

  has_many :invitations,  dependent: :destroy
  has_many :event_teammates, dependent: :destroy
  has_many :reviewer_event_teammates, -> { where(role: ['reviewer', 'program_team', 'organizer']) }, class_name: 'EventTeammate'
  has_many :reviewer_events, through: :reviewer_event_teammates, source: :event
  has_many :organizer_event_teammates, -> { where(role: 'organizer') }, class_name: 'EventTeammate'
  has_many :organizer_events, through: :organizer_event_teammates, source: :event
  has_many :speakers,     dependent: :destroy
  has_many :ratings,      dependent: :destroy
  has_many :comments,     dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :proposals, through: :speakers, source: :proposal

  validates :bio, length: { maximum: 500 }
  validates :name, presence: true, allow_nil: true
  validates_uniqueness_of :email, allow_blank: true
  validates_format_of :email, with: Devise.email_regexp, allow_blank: true, if: :email_changed?
  validates_presence_of :email, on: :create, if: -> { provider.nil? }
  validates_presence_of :email, on: :update
  validates_presence_of :password, on: :create
  validates_confirmation_of :password, on: :create
  validates_length_of :password, within: Devise.password_length, allow_blank: true

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      password = Devise.friendly_token[0,20]
      user.name = auth['info']['name']   # assuming the user model has a name
      user.email = auth['info']['email'] || ''
      user.password = password
      user.password_confirmation = password
    end
  end

  def assign_open_invitations
    if email
      Invitation.where("LOWER(email) = ? AND state = ? AND user_id IS NULL",
        email.downcase, Invitation::State::PENDING).each do |invitation|
        invitation.update_column(:user_id, id)
      end
    end
  end

  def update_bio
    update(bio: speakers.last.bio) if bio.blank?
  end

  def gravatar_hash
    Digest::MD5.hexdigest email.to_s.downcase
  end

  def connected?(provider)
    self.provider == provider
  end

  def complete?
    self.name.present? && self.email.present?
  end

  def organizer?
    organizer_events.count > 0
  end

  def organizer_for_event?(event)
    event_teammates.organizer.for_event(event).size > 0
  end

  def reviewer?
    reviewer_events.count > 0
  end

  def reviewer_for_event?(event)
    event_teammates.reviewer.for_event(event).size > 0
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
    self.event_teammates.collect {|p| p.role}.uniq.join(", ")
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
#  created_at             :datetime
#  updated_at             :datetime
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  provider               :string
#  uid                    :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
