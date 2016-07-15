class ConferenceDaySlot

  attr_reader :conference_day, :start_time, :event

  def initialize(conference_day, start_time, event)
    @conference_day = conference_day
    @start_time = start_time
    @event = event
  end

  def sessions
    sessions = raw_sessions
    unless conference_wide?
      sessions = sessions.by_room
      missing_rooms(sessions).each do |room_id|
        index = room_ids.index(room_id)
        sessions.insert(index, nil)
      end
    end
    sessions
  end

  def end_time
    if conference_wide?
      conference_wide_session.end_time
    else
      start_time + TimeSlot::STANDARD_LENGTH
    end
  end

  def conference_wide?
    raw_sessions.count == 1
  end

  def conference_wide_session
    raw_sessions.first
  end


  private
  def rooms
    @rooms ||= @event.rooms.by_grid_position
  end

  def missing_rooms(sessions)
    room_ids - sessions.map(&:room_id)
  end

  def room_ids
    @room_ids ||= rooms.map(&:id)
  end

  def raw_sessions
    @raw_sessions ||= TimeSlot.where(conference_day: conference_day, start_time: start_time, event_id: event.id)
  end

  def sessions_from_previous_time_slot
    @previous_sessions ||= TimeSlot.where(conference_day: conference_day, start_time: start_time - TimeSlot::STANDARD_LENGTH, event_id: event.id)
  end
end