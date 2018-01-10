class Staff::GridsController < Staff::ApplicationController
  include ScheduleSupport

  def show
    @schedule = Schedule.new(current_event)
    @counts = EventStats.new(current_event).schedule_counts
  end
end
