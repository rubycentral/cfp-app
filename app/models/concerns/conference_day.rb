class ConferenceDay
  include TimeHelpers
  attr_reader :time_slots

  def initialize(day, event)
    start_times = Session.where(conference_day: day, event_id: event.id).pluck(:start_time).uniq.map do |start_time|
      [TimeHelpers.with_correct_time_zone(start_time), start_time]
    end.sort_by { |start_time| start_time.first }
    @time_slots = start_times.map do |_, start_time|
      TimeSlot.new(day, start_time, event)
    end
  end

  def session_empty?(session, index, time_slot)
    previous_time_slot = time_slots[time_slots.index(time_slot) - 1]
    previous_session = previous_time_slot.sessions[index]
    session.nil? && (previous_session.nil? || (previous_session && !previous_session.takes_two_time_slots?))
  end
end