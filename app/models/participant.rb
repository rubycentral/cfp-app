class Participant < ActiveRecord::Base
  belongs_to :event
  belongs_to :user

  scope :for_event, -> (event) { where(event: event) }
  scope :recent, -> { order('created_at DESC') }

  scope :organizer, -> { where(role: 'organizer') }
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
# Table name: participants
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
#  index_participants_on_event_id  (event_id)
#  index_participants_on_user_id   (user_id)
#
