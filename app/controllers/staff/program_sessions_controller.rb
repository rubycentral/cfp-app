class Staff::ProgramSessionsController < Staff::ApplicationController
  before_action :enable_staff_program_subnav
  before_action :set_proposal_counts

  decorates_assigned :program_session, with: Staff::ProgramSessionDecorator
  decorates_assigned :sessions, with: Staff::ProgramSessionDecorator
  decorates_assigned :waitlisted_sessions, with: Staff::ProgramSessionDecorator

  def index
    @sessions = @event.program_sessions.active_or_inactive
    @waitlisted_sessions = @event.program_sessions.waitlisted

    session[:prev_page] = { name: 'Program', path: event_staff_program_sessions_path(@event) }
  end

  def show
    @program_session = @event.program_sessions.find(params[:id])
    @speakers = @program_session.speakers
  end
end
