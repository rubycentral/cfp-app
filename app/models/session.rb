class Session < ActiveRecord::Base
  belongs_to :proposal
  belongs_to :room
  belongs_to :track
  belongs_to :event

  STANDARD_LENGTH = 40.minutes

  scope :day, -> (num) { where(conference_day: num).order(:start_time).order(room_name: :asc) }
  scope :start_times_by_day, -> (num) { day(num+1).pluck(:start_time).uniq }
  scope :by_room, -> do
    joins(:room).where.not(rooms: {grid_position: nil}).sort_by { |session| session.room.grid_position }
  end

  def self.import(file)
    raw_json = file.read # maybe open as well
    parsed_sessions = JSON.parse(raw_json)
    parsed_sessions["sessions"].each do |session|
      session.delete("session_id")
      session.delete("desc")
      self.create!(session)
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
#  start_time     :time
#  end_time       :time
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
