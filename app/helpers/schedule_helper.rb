module ScheduleHelper
  #
  # def schedule_room_names
  #   [
  #     "202 (Level 2)",
  #     "204 AB",
  #     "204 CDE",
  #     "204 FG",
  #     "204 H",
  #     "204 IJ"
  #   ]
  # end
  #
  # def schedule_day
  #   Session.pluck(:conference_day).uniq.sort.each { |d| puts d }
  # end
  #
  def row_time(time_slot)
    "#{time_slot.start_time.to_s(:time_only)} - #{time_slot.end_time.to_s(:time_only)}"
  end
end