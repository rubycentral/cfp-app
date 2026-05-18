class Speaker < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :event
  belongs_to :proposal, optional: true
  belongs_to :program_session, optional: true

  has_many :proposals, through: :user

  serialize :info, type: Hash, coder: YAML

  validates :event, presence: true
  validates :bio, length: {maximum: 500}
  validates :name, :email, presence: true, unless: :skip_name_email_validation
  validates_format_of :email, with: /\A[^@\s]+@[^@\s]+\z/  # equivalent to Devise.email_regexp

  attr_accessor :skip_name_email_validation

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

  def github_account
    user&.github_account
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
