class TimeSlotBulk
  include ActiveModel::Model

  attr_accessor :day, :rooms, :start_times, :duration, :session_format
  validates :day, :rooms, :start_times, :duration, presence: true

  def day=(day)
    @day = day.to_i
  end

  def rooms=(rooms)
    rooms = rooms.select(&:present?)
    @rooms = Room.where(id: rooms)
  end

  def start_times=(start_times)
    return if start_times.blank?
    start_times = start_times.split(/\s*,\s*/)
    @start_times = start_times.map {|t| Time.parse(t)}
  end

  def duration=(duration)
    @duration = duration.to_i
  end

  def build_time_slots
    slots = []
    rooms.each do |room|
      start_times.each do |starts_at|
        slots << TimeSlot.new(conference_day: day, room: room, start_time: starts_at, end_time: starts_at + duration.minutes)
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