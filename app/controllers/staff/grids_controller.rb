class Staff::GridsController < Staff::ApplicationController
  include ScheduleSupport

  def show
    @schedule = Schedule.new(current_event)
    @sessions = current_event.program_sessions
    @unscheduled_sessions = current_event.program_sessions.unscheduled
    @schedule_counts = EventStats.new(current_event).schedule_counts
    @event = current_event
  end
end
