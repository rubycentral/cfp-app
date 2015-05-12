class TimeSlot

  attr_reader :conference_day, :start_time, :event

  def initialize(conference_day, start_time, event)
    @conference_day = conference_day
    @start_time = start_time
    @event = event
  end

  def sessions
    @sessions ||= Session.where(conference_day: conference_day, start_time: start_time, event_id: event.id)
  end

  def end_time
    if conference_wide?
      conference_wide_session.end_time
    else
      corrected_start_time + Session::STANDARD_LENGTH
    end
  end

  def conference_wide?
    sessions.count == 1
  end

  def conference_wide_session
    sessions.first
  end

  def corrected_start_time
    TimeHelpers.with_correct_time_zone(start_time)
  end
end