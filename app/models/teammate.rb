class Teammate < ApplicationRecord
  NOTIFICATION_PREFERENCE_LABELS = {
    'all' => 'All Via Email',
    'mentions' => 'Mention Only Via Email',
    'in_app_only' => 'In App Only'
  }

  enum :role, {reviewer: 'reviewer', program_team: 'program team', organizer: 'organizer'}, scopes: false

  enum :state, {pending: 'pending', accepted: 'accepted', declined: 'declined'}, default: :pending do
    event :accept do
      transition :pending => :accepted

      before do |user|
        self.user = user
        self.accepted_at = Time.current
      end
    end

    event :decline do
      transition :pending => :declined

      before do
        self.declined_at = Time.current
      end
    end
  end

  enum :notification_preference, {all: 'all', mentions: 'mentions', in_app_only: 'in_app_only'}, default: :all, scopes: false, instance_methods: false

  belongs_to :event
  belongs_to :user, optional: true

  validates_uniqueness_of :email, scope: :event
  validates_uniqueness_of :mention_name, scope: :event, allow_blank: true
  validates :email, :event, :role, presence: true
  validates_format_of :email, :with => /@/
  validates_format_of :mention_name, with: /\A\w+\z/, message: "cannot include punctuation or spaces", allow_blank: true

  scope :for_event, -> (event) { where(event: event) }
  scope :alphabetize, -> { joins(:user).merge(User.order(name: :asc)) }
  scope :notify, -> { where(notifications: true) }

  scope :organizer, -> { where(role: "organizer") }
  scope :program_team, -> { where(role: [:program_team, :organizer]) }
  scope :reviewer, -> { where(role: [:reviewer, :program_team, :organizer]) }

  scope :active, -> { accepted }
  scope :invitations, -> { where(state: [:pending, :declined]) }

  scope :all_emails, -> { where(notification_preference: :all) }

  def name
    user ? user.name : ""
  end

  def ratings_count(current_event)
    self.user.ratings.not_withdrawn.for_event(current_event).size
  end

  def invite
    self.token = Digest::SHA1.hexdigest(Time.current.to_s + email + rand(1000).to_s)
    self.invited_at = Time.current
    save
  end
end

# == Schema Information
#
# Table name: teammates
#
#  id                      :integer          not null, primary key
#  event_id                :integer
#  user_id                 :integer
#  role                    :string
#  email                   :string
#  state                   :string
#  token                   :string
#  invited_at              :datetime
#  accepted_at             :datetime
#  declined_at             :datetime
#  created_at              :datetime
#  updated_at              :datetime
#  notification_preference :string           default("all")
#  mention_name            :string
#
# Indexes
#
#  index_teammates_on_event_id  (event_id)
#  index_teammates_on_user_id   (user_id)
#
