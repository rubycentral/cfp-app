class Staff::GridsController < Staff::ApplicationController
  include ScheduleSupport

  def show
    @schedule = Schedule.new(current_event)
  end
end
