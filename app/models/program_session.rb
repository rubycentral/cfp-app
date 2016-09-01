class ProgramSession < ActiveRecord::Base
  ACTIVE = 'active'
  INACTIVE = 'inactive'
  WAITLISTED = 'waitlisted'

  STATES = [INACTIVE, ACTIVE, WAITLISTED]

  belongs_to :event
  belongs_to :proposal
  belongs_to :track
  belongs_to :session_format
  has_one :time_slot
  has_many :speakers

  validates :event, :session_format, :title, :state, presence: true

  scope :unscheduled, -> do
    where(state: ACTIVE).where.not(id: TimeSlot.pluck(:program_session_id))
  end
  scope :active, -> { where(state: ACTIVE) }
  scope :inactive, -> { where(state: INACTIVE) }
  scope :waitlisted, -> { where(state: WAITLISTED) }

  def self.create_from_proposal(proposal)
    self.transaction do
      ps = ProgramSession.create!(event_id: proposal.event_id,
                                  proposal_id: proposal.id,
                                  title: proposal.title,
                                  abstract: proposal.abstract,
                                  track_id: proposal.track_id,
                                  session_format_id: proposal.session_format_id)

      #attach proposal speakers to new program session
      ps.speakers << proposal.speakers
      ps.speakers.each do |speaker|
        (speaker.speaker_name = speaker.user.name) if speaker.speaker_name.blank?
        (speaker.speaker_email = speaker.user.email) if speaker.speaker_email.blank?
        speaker.save!
      end
      ps
    end
  end

  def multiple_speakers?
    speakers.count > 1
  end

  def scheduled?
    time_slot.present?
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
