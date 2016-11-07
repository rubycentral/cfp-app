class ConferenceDay
  attr_reader :conf_slots

  def initialize(day, event)
    start_times = TimeSlot.where(conference_day: day, event_id: event.id).pluck(:start_time).uniq.sort_by { |start_time| start_time }
    @conf_slots = start_times.map do |start_time|
      ConferenceDaySlot.new(day, start_time, event)
    end
  end

  def session_empty?(session, index, time_slot)
    previous_time_slot = conf_slots[conf_slots.index(time_slot) - 1]
    previous_session = previous_time_slot.sessions[index]
    session.nil? && (previous_session.nil? || (previous_session && !previous_session.takes_two_time_slots?))
  end
end