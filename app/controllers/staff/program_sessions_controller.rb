class Staff::ProgramSessionsController < Staff::ApplicationController
  before_action :enable_staff_program_subnav
  before_action :set_proposal_counts

  decorates_assigned :active_sessions, with: Staff::ProgramSessionDecorator
  decorates_assigned :waitlisted_sessions, with: Staff::ProgramSessionDecorator

  def index
    @sessions = @event.program_sessions.active_or_inactive
    @waitlisted_sessions = @event.program_sessions.waitlisted

    session[:prev_page] = { name: 'Program', path: event_staff_program_sessions_path(@event) }

    @sessions = Staff::ProgramSessionDecorator.decorate_collection(@sessions)
    @waitlisted_sessions = Staff::ProgramSessionDecorator.decorate_collection(@waitlisted_sessions)
  end
end
