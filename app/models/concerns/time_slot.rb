class TimeSlot

  attr_reader :conference_day, :start_time

  def initialize(conference_day, start_time)
    @conference_day = conference_day
    @start_time = start_time
  end

  def sessions
    @sessions ||= Session.where conference_day: conference_day, start_time: start_time
  end

  def end_time
    if conference_wide?
      conference_wide_session.end_time
    else
      start_time + Session::STANDARD_LENGTH
    end
  end

  def conference_wide?
    sessions.count == 1
  end

  def conference_wide_session
    sessions.first
  end
end