class Schedule
  attr_reader :event, :slots

  def initialize(event)
    @event = event
  end

  def each_day
    (1..event.days).each do |d|
      yield(d, slots[d] || {})
    end
  end

  def each_room(day)
    rooms.each do |r|
      room_slots = slots[day][r] if slots[day]
      yield(r, room_slots || [])
    end
  end

  def rooms
    @rooms ||= init_rooms
  end

  def slots
    @slots ||= init_slots
  end

  private

  def init_rooms
    event.rooms.grid_order
  end

  def init_slots
    slots_by_day = event.time_slots.grid_order
        .includes(:room, :track, program_session: :speakers)
    slots_by_day = slots_by_day.group_by(&:conference_day)
    slots_by_day.each {|d, slots| slots_by_day[d] = slots.group_by(&:room)}
    slots_by_day
  end
end