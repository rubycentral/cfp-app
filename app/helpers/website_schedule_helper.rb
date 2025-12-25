module WebsiteScheduleHelper
  def schedule_for_day(schedule, day_number)
    schedule.select { |time_slot| time_slot[:conference_day] == day_number }
            .filter { |time_slot| !time_slot[:title].blank? || time_slot.program_session }
            .sort_by {|time_slot| time_slot[:start_time] }
            .group_by {|time_slot| time_slot[:start_time] }
            .values
  end
end
