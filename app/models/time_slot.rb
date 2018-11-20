class TimeSlot < ApplicationRecord
  belongs_to :program_session
  belongs_to :room
  belongs_to :track
  belongs_to :event

  attr_reader :session_duration

  DEFAULT_TIME = Time.current.beginning_of_day.change(hour: 9)
  DEFAULT_DURATION = 60 # minutes
  STANDARD_LENGTH = 40.minutes

  before_save :clear_fields_if_session

  scope :day, -> (num) { where(conference_day: num).order(:start_time).order(room_name: :asc) }
  scope :start_times_by_day, -> (num) { day(num+1).pluck(:start_time).uniq }
  scope :by_room, -> do
    joins(:room).where.not(rooms: {grid_position: nil}).sort_by { |slot| slot.room.grid_position }
  end
  scope :grid_order, -> { joins(:room).order(:conference_day, :start_time, 'rooms.grid_position') }

  scope :scheduled, -> { where.not(title: [nil, ""]).or(where.not(program_session_id: nil)) }
  scope :empty, -> { where(program_session: nil, title: [nil, ""]) }

  validate :end_time_later_than_start_time

  validates :room_id, :conference_day, presence: true

  def self.import(file)
    raw_json = file.read # maybe open as well
    parsed_slots = JSON.parse(raw_json)
    parsed_slots["sessions"].each do |slot|
      slot.delete("session_id")
      slot.delete("desc")
      self.create!(slot)
    end
  end

  def self.bulk_build(params)
  end

  def self.track_names
    pluck(:track_name).uniq
  end

  def clear_fields_if_session
    if program_session
      self.title = ''
      self.presenter = ''
      self.description = ''
      self.track_id = nil
    end
  end

  def takes_two_time_slots?
    (end_time - start_time) > STANDARD_LENGTH
  end

  def track_name
    track.try(:name)
  end

  def room_name
    room.try(:name)
  end

  def session_title
    program_session && program_session.title
  end

  def session_presenter
    session_speaker_names
  end

  def session_description
    program_session && program_session.abstract
  end

  def session_suggested_duration
    if program_session
      program_session.suggested_duration
    else
     "N/A"
    end
  end

  def session_track_id
    program_session && program_session.track_id
  end

  def session_track_name
    program_session && program_session.track_name
  end

  def session_speaker_names
    program_session && program_session.speaker_names
  end

  def session_format_name
    program_session && program_session.session_format.try(:name)
  end

  def session_confirmation_notes
    program_session && program_session.confirmation_notes
  end

  def session_duration
    (end_time - start_time).to_i/60
  end

  def end_time_later_than_start_time
    if session_duration <= 0
      errors.add(:end_time, 'must be later than start time')
    end
  end
end

# == Schema Information
#
# Table name: time_slots
#
#  id                 :integer          not null, primary key
#  program_session_id :integer
#  room_id            :integer
#  event_id           :integer
#  conference_day     :integer
#  start_time         :time
#  end_time           :time
#  title              :text
#  description        :text
#  presenter          :text
#  created_at         :datetime
#  updated_at         :datetime
#  track_id           :integer
#
# Indexes
#
#  index_time_slots_on_conference_day      (conference_day)
#  index_time_slots_on_event_id            (event_id)
#  index_time_slots_on_program_session_id  (program_session_id)
#  index_time_slots_on_room_id             (room_id)
#  index_time_slots_on_track_id            (track_id)
#
