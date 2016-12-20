class BulkTimeSlot
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

    slots = []
    rooms.each do |room|
      start_times.each do |starts_at|
        end_time = Time.parse(starts_at) + duration.minutes
        slots << TimeSlot.new(event: event, conference_day: day, room: room,
                              start_time: starts_at, end_time: end_time.to_s(:time) )
      end
    end
    slots
  end

  def create_time_slots
    slots = build_time_slots
    TimeSlot.transaction do
      slots.each do |s|
        unless s.save
          errors.push(*s.errors)
        end
      end
      raise ActiveRecord::Rollback unless errors.blank?
    end
    errors.blank?
  end

end