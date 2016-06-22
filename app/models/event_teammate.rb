class EventTeammate < ActiveRecord::Base
  belongs_to :event
  belongs_to :user

  scope :for_event, -> (event) { where(event: event) }
  scope :recent, -> { order('created_at DESC') }

  scope :organizer, -> { where(role: 'organizer') }
  scope :program_team, -> { where(role: ['program team', 'organizer']) }
  scope :reviewer, -> { where(role: ['reviewer', 'organizer']) }

  validates :user, :event, :role, presence: true
  validates :user_id, uniqueness: {scope: :event_id}

  def should_be_notified?
    notifications
  end

  def comment_notifications
    if notifications
      "\u2713"
    else
      "X"
    end
  end
end


# == Schema Information
#
# Table name: event_teammates
#
#  id            :integer          not null, primary key
#  event_id      :integer
#  user_id       :integer
#  role          :string
#  notifications :boolean          default(TRUE)
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_event_teammates_on_event_id  (event_id)
#  index_event_teammates_on_user_id   (user_id)
#
