class TimeSlotBulk
  include ActiveModel::Model

  attr_accessor :event, :day, :rooms, :start_times, :duration, :session_format
  validates :day, :rooms, :start_times, :duration, presence: true

  def event=(event)
    @event = event
  end

  def day=(day)
    @day = day.to_i
  end

  def rooms=(rooms)
    @rooms = rooms.select(&:present?).map(&:to_i)
  end

  def start_times=(start_times)
    @start_times = start_times || ''
  end

  def duration=(duration)
    @duration = duration.to_i
  end

  def build_time_slots
    rooms = event.rooms.where(id: @rooms)
    start_times = @start_times.split(/\s*,\s*/)
    start_times = start_times.map {|t| Time.parse(t)}

    slots = []
    rooms.each do |room|
      start_times.each do |starts_at|
        slots << TimeSlot.new(event: event, conference_day: day, room: room,
                              start_time: starts_at, end_time: starts_at + duration.minutes)
      end
    end
    slots
  end

  def create_time_slots
    slots = build_time_slots
    # transaction do
    #   slots.each do |s|
    #     unless s.save
    #       errors.push(*s.errors)
    #     end
    #   end
    # end
    errors.blank?
  end

end