class ProgramSession < ActiveRecord::Base
  LIVE = 'live'
  DRAFT = 'draft'
  WAITLISTED = 'waitlisted'

  STATES = [DRAFT, LIVE, WAITLISTED]

  belongs_to :event
  belongs_to :proposal
  belongs_to :track
  belongs_to :session_format
  has_one :time_slot
  has_many :speakers

  accepts_nested_attributes_for :speakers

  validates :event, :session_format, :title, :state, presence: true

  serialize :info, Hash

  after_destroy :destroy_speakers

  scope :unscheduled, -> do
    where(state: LIVE).where.not(id: TimeSlot.pluck(:program_session_id))
  end
  scope :sorted_by_title, -> { order(:title)}
  scope :live, -> { where(state: LIVE) }
  scope :draft, -> { where(state: DRAFT) }
  scope :waitlisted, -> { where(state: WAITLISTED) }
  scope :live_or_draft, -> { where(state: [LIVE, DRAFT]) }
  scope :without_proposal, -> { where(proposal: nil) }
  scope :in_track, ->(track) do
    track = nil if track.try(:strip).blank?
    where(track: track)
  end
  scope :emails, -> { joins(:speakers).pluck(:speaker_email).uniq }

  def self.create_from_proposal(proposal)
    self.transaction do
      ps = ProgramSession.create!(event_id: proposal.event_id,
                                  proposal_id: proposal.id,
                                  title: proposal.title,
                                  abstract: proposal.abstract,
                                  track_id: proposal.track_id,
                                  session_format_id: proposal.session_format_id,
                                  state: proposal.waitlisted? ? WAITLISTED : LIVE
      )

      #attach proposal speakers to new program session
      ps.speakers << proposal.speakers
      ps.speakers.each do |speaker|
        (speaker.speaker_name = speaker.user.name) if speaker.speaker_name.blank?
        (speaker.speaker_email = speaker.user.email) if speaker.speaker_email.blank?
        (speaker.bio = speaker.user.bio) if speaker.bio.blank?
        speaker.save!
      end
      ps
    end
  end

  def multiple_speakers?
    speakers.count > 1
  end

  def speaker_names
    speakers.map(&:name).join(', ')
  end

  def speaker_emails
    speakers.map(&:email).join(', ')
  end

  def session_format_name
    session_format.try(:name)
  end

  def track_name
    track.try(:name) || 'General'
  end

  def confirmation_notes?
    proposal.try(:confirmation_notes?)
  end

  def confirmation_notes
    proposal.try(:confirmation_notes)
  end

  def scheduled?
    time_slot.present?
  end

  def video_url
    info[:video_url]
  end

  def slides_url
    info[:slides_url]
  end

  def video_url=(video_url)
    info[:video_url] = video_url
  end

  def slides_url=(slides_url)
    info[:slides_url] = slides_url
  end

  private

  def destroy_speakers
    speakers.each { |speaker| speaker.destroy unless speaker.proposal_id.present? }
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
#  state             :text             default("draft")
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  info              :text
#
# Indexes
#
#  index_program_sessions_on_event_id           (event_id)
#  index_program_sessions_on_proposal_id        (proposal_id)
#  index_program_sessions_on_session_format_id  (session_format_id)
#  index_program_sessions_on_track_id           (track_id)
#
