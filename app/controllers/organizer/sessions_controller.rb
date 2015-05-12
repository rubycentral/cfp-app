class Organizer::SessionsController < Organizer::SchedulesController

  before_action :set_session, only: [ :update, :destroy, :edit ]
  before_action :set_sessions, only: :index

  helper_method :session_decorator

  def new
    if session[:sticky_session]
      @session = @event.sessions.build(session[:sticky_session])
      @event = @event.decorate
    else
      date = DateTime.now.beginning_of_hour
      @session = @event.sessions.build(start_time: date, end_time: date)
      @event = @event.decorate
    end

    respond_to do |format|
      format.js
    end
  end

  def index
    @rooms = @event.rooms.by_grid_position
    respond_to do |format|
      format.html
      format.csv { send_data sessions.to_csv }
      format.json { render_json(sessions) }
    end
  end

  def create
    save_and_add = params[:button] == 'save_and_add'

    @session = @event.sessions.build(session_params)

    f = save_and_add ? flash : flash.now
    if @session.save
      f[:info] = "Session Created"

      session[:sticky_session] = {
        conference_day: @session.conference_day,
        start_time: @session.start_time,
        end_time: @session.end_time,
        room_id: @session.room ? @session.room.id : nil
      }
    else
      f[:warning] = "There was a problem saving your session"
    end

    respond_to do |format|
      format.js do
        render locals: { save_and_add: save_and_add }
      end
    end
  end

  def edit
  end

  def update
    @session.update_attributes(session_params)
    flash.now[:info] = "Session sucessfully edited"

    respond_to do |format|
      format.js
    end
  end

  def destroy
    session_id = @session.id
    @session.destroy
    respond_to do |format|
      format.js do
        render locals: { session_id: session_id }
      end
    end
  end

private
  def session_params
    params.require(:session).permit(:conference_day, :start_time, :end_time, :title, :description, :presenter, :room_id, :track_id, :proposal_id)
  end

  def set_session
    @session = Session.find(params[:id])
  end

  def session_decorator
    @session_decorator ||= @session.decorate
  end
end
