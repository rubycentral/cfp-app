class Session < ActiveRecord::Base
  belongs_to :proposal
  belongs_to :room
  belongs_to :track
  belongs_to :event

  STANDARD_LENGTH = 40.minutes

  scope :day, -> (num) { where(conference_day: num).order(:start_time).order(room_name: :asc) }
  scope :start_times_by_day, -> (num) { day(num+1).pluck(:start_time).uniq }

  def self.import(file)
    raw_json = file.read # maybe open as well
    parsed_sessions = JSON.parse(raw_json)
    parsed_sessions["sessions"].each do |session|
      session.delete("session_id")
      session.delete("desc")
      self.create!(session)
    end
  end

  # def self.order_by_room_name(room_names)
  #   sessions = all.to_a
  #   room_names.map do |room_name|
  #     sessions.find { |s| s.room_name == room_name }
  #   end
  # end

  def self.time_slots(conference_day)
    where(conference_day: conference_day).order(:start_time).pluck(:start_time).uniq.map do |start_time|
      TimeSlot.new(conference_day, start_time)
    end
  end

  def self.track_names
    pluck(:track_name).uniq
  end

  def takes_two_time_slots?
    (end_time - start_time) > STANDARD_LENGTH
  end

  def desc
    if proposal
      proposal.abstract
    else
      description
    end
  end
end

# == Schema Information
#
# Table name: sessions
#
#  id             :integer          not null, primary key
#  conference_day :integer
#  start_time     :datetime
#  end_time       :datetime
#  title          :text
#  description    :text
#  presenter      :text
#  room_id        :integer
#  track_id       :integer
#  proposal_id    :integer
#  event_id       :integer
#  created_at     :datetime
#  updated_at     :datetime
#
# Indexes
#
#  index_sessions_on_event_id  (event_id)
#
