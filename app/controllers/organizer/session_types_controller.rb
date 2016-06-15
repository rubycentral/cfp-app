class Organizer::SessionTypesController < Organizer::ApplicationController
  before_action :set_session_type, only: [:edit, :update, :destroy]

  def index
    @session_types = @event.session_types
  end

  def new
    @session_type = SessionType.new
  end

  def edit

  end

  def create
    @session_type = @event.session_types.build(session_type_params)

    if @session_type.save
      flash[:info] = 'Session type created.'
      redirect_to organizer_event_session_types_path(@event)
    else
      flash[:danger] = 'Unable to create session type.'
      render :edit
    end
  end

  def update
    if @session_type.update_attributes(session_type_params)
      flash[:info] = 'Session type updated.'
      redirect_to organizer_event_session_types_path(@event)
    else
      flash[:danger] = 'Unable to update session type.'
      render :edit
    end
  end

  def destroy
    if @session_type.destroy
      flash[:info] = 'Session type destroyed.'
    else
      flash[:danger] = 'Unable to destroy session type.'
    end

    redirect_to organizer_event_session_types_path(@event)
  end

  private

  def set_session_type
    @session_type = @event.session_types.find(params[:id])
  end

  def session_type_params
    params.require(:session_type)
        .permit(:id, :name, :description, :event_id, :duration, :public)
  end

end