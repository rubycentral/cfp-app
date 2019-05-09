class Staff::GridsController < Staff::ApplicationController
  include ScheduleSupport

  def show
    @schedule = Schedule.new(current_event)
    @counts = EventStats.new(current_event).schedule_counts
    @sessions = current_event.program_sessions
    @unscheduled_sessions = @sessions.unscheduled
    @tracks = current_event.tracks.sort_by_name
  end
end
