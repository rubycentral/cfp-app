module WebsiteScheduleHelper

  def schedule_for_day(schedule, day_number)
    schedule.select { |program_session| program_session[:conference_day] == day_number }
            .sort_by {|program_session| program_session[:start_time] }
            .group_by {|program_session| program_session[:start_time] }
            .values
  end
end