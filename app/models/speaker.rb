class Speaker < ApplicationRecord
  AGE_RANGES = [
    "Under 18 years old",
    "18-24 years old",
    "25-34 years old",
    "35-44 years old",
    "45-54 years old",
    "55-64 years old",
    "65-74 years old",
    "75 years or older",
    "Decline to say"
  ].freeze

  GENDER_PRONOUNS = [
    "he/him/his",
    "she/her/hers",
    "they/them/theirs",
    "something not listed",
    "Decline to say"
  ].freeze

  # Racial categories according to the Census
  RACIAL_CATEGORIES = [
    "American Indian or Alaska Native", "Asian", "Black or African American",
    "Hispanic or Latino", "Native Hawaiian or Other Pacific Islander",
    "Native American or Alaskan Natives", "Non-Hispanic White",
    "Two or more races", "Other", "Decline to say"
  ].freeze

  # NOTE: This is a temporary field to support an extra question in the CFP
  HOUSTON_OR_PROVIDENCE = [
    "Only RubyConf in Texas from Nov 29 - Dec 1",
    "Only RubyConf Mini in Rhode Island from Nov 15 - Nov 17",
    "Prefer RubyConf in Texas from Nov 29 - Dec 1, open to RubyConf Mini in Rhode Island from Nov 15 - Nov 17",
    "Prefer RubyConf Mini in Rhode Island from Nov 15 - Nov 17, open to RubyConf in Texas from Nov 29 - Dec 1"
  ]

  belongs_to :user
  belongs_to :event
  belongs_to :proposal
  belongs_to :program_session

  has_many :proposals, through: :user
  has_many :program_sessions

  serialize :info, Hash

  validates :event, presence: true
  validates :bio, length: {maximum: 500}
  validates :name, :email, presence: true, unless: :skip_name_email_validation
  validates_format_of :email, with: Devise.email_regexp

  # NOTE: This is a temporary field to support an extra question in the CFP
  validates :houston_or_providence, presence: true

  attr_accessor :skip_name_email_validation

  before_validation :set_houston_or_providence_in_test

  scope :in_program, -> { where.not(program_session_id: nil) }
  scope :a_to_z, -> { order(:speaker_name) }

  def name
    speaker_name.present? ? speaker_name : user.try(:name)
  end

  def email
    speaker_email.present? ? speaker_email : user.try(:email)
  end

  def gravatar_hash
    User.gravatar_hash(email)
  end

  private

  # NOTE: this is a hack to avoid updating a bunch of tests for this hackish feature
  def set_houston_or_providence_in_test
    if Rails.env == "test" && houston_or_providence.blank?
      self.houston_or_providence = HOUSTON_OR_PROVIDENCE.first
    end
  end
end

# == Schema Information
#
# Table name: speakers
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  event_id           :integer
#  proposal_id        :integer
#  program_session_id :integer
#  speaker_name       :string
#  speaker_email      :string
#  bio                :text
#  info               :text
#  created_at         :datetime
#  updated_at         :datetime
#  age_range          :string
#  ethnicity          :string
#  first_time_speaker :boolean
#  pronouns           :string
#
# Indexes
#
#  index_speakers_on_event_id            (event_id)
#  index_speakers_on_program_session_id  (program_session_id)
#  index_speakers_on_proposal_id         (proposal_id)
#  index_speakers_on_user_id             (user_id)
#
