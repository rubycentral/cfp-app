class Organizer::SchedulesController < Organizer::ApplicationController
  decorates_assigned :sessions

  protected

  def set_sessions
    @sessions =
      @event.sessions.includes(:track, :room, proposal: { speakers: :person })
  end
end
