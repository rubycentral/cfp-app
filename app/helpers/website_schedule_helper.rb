module WebsiteScheduleHelper

  def schedule_for_day(schedule, day_number)
    schedule.select { |session| session[:conference_day] == day_number }
            .sort_by {|session| session[:start_time] }
            .group_by {|session| session[:start_time] }
            .values
  end
end