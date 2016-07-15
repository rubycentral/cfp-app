class TimeSlot < ActiveRecord::Base
  belongs_to :program_session
  belongs_to :room
  belongs_to :event

  STANDARD_LENGTH = 40.minutes

  scope :day, -> (num) { where(conference_day: num).order(:start_time).order(room_name: :asc) }
  scope :start_times_by_day, -> (num) { day(num+1).pluck(:start_time).uniq }
  scope :by_room, -> do
    joins(:room).where.not(rooms: {grid_position: nil}).sort_by { |slot| slot.room.grid_position }
  end

  def self.import(file)
    raw_json = file.read # maybe open as well
    parsed_slots = JSON.parse(raw_json)
    parsed_slots["sessions"].each do |slot|
      slot.delete("session_id")
      slot.delete("desc")
      self.create!(slot)
    end
  end

  def self.track_names
    pluck(:track_name).uniq
  end

  def takes_two_time_slots?
    (end_time - start_time) > STANDARD_LENGTH
  end

  def desc
    if program_session
      program_session.abstract
    else
      description
    end
  end

end

# == Schema Information
#
# Table name: time_slots
#
#  id                 :integer          not null, primary key
#  conference_day     :integer
#  start_time         :time
#  end_time           :time
#  title              :text
#  description        :text
#  presenter          :text
#  program_session_id :integer
#  room_id            :integer
#  event_id           :integer
#  created_at         :datetime
#  updated_at         :datetime
#
# Indexes
#
#  index_time_slots_on_event_id            (event_id)
#  index_time_slots_on_program_session_id  (program_session_id)
#  index_time_slots_on_room_id             (room_id)
#
