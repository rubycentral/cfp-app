module ScheduleHelper

  def row_time(time_slot)
    if time_slot && time_slot.start_time
      fmt = "%l:%M%p"
      "#{time_slot.start_time.strftime(fmt)} - #{time_slot.end_time.strftime(fmt)}"
    end
  end
end