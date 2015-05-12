module ScheduleHelper

  def row_time(time_slot)
    fmt = "%l:%M%p"
    "#{time_slot.corrected_start_time.strftime(fmt)} - #{time_slot.end_time.strftime(fmt)}"
  end
end