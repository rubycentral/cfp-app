class ProgramSession < ActiveRecord::Base
  ACTIVE = 'active'
  INACTIVE = 'inactive'

  STATES = [INACTIVE, ACTIVE]

  belongs_to :event
  belongs_to :proposal
  belongs_to :track
  belongs_to :session_format
  has_one :time_slot

  validates :event, :session_format, :title, :state, presence: true

  scope :unscheduled, -> do
    where(state: ACTIVE).where.not(id: TimeSlot.pluck(:program_session_id))
  end
end

# == Schema Information
#
# Table name: program_sessions
#
#  id                :integer          not null, primary key
#  event_id          :integer
#  proposal_id       :integer
#  title             :text
#  abstract          :text
#  track_id          :integer
#  session_format_id :integer
#  state             :text             default("active")
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_program_sessions_on_event_id           (event_id)
#  index_program_sessions_on_proposal_id        (proposal_id)
#  index_program_sessions_on_session_format_id  (session_format_id)
#  index_program_sessions_on_track_id           (track_id)
#
