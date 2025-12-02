class Staff::Grids::ProgramSessionsController < Staff::ApplicationController
  include ScheduleSupport

  def show
    @session = current_event.program_sessions.find(params[:id])
    render partial: 'show_dialog', locals: {session: @session}
  end
end  