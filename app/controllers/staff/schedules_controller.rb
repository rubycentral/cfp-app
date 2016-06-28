class Staff::SchedulesController < Staff::ApplicationController
  decorates_assigned :sessions

  protected

  def set_sessions
    @sessions =
      @event.sessions.includes(:track, :room, proposal: { speakers: :user })
  end
end
