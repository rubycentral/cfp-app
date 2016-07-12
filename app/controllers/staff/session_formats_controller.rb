class Staff::SessionFormatsController < Staff::ApplicationController
  before_action :set_session_format, only: [:edit, :update, :destroy]

  def index
    @session_formats = @event.session_formats
  end

  def new
    @session_format = SessionFormat.new(public: true)
  end

  def edit
  end

  def create
    @session_format = @event.session_formats.build(session_format_params)

    if @session_format.save
      flash[:info] = 'Session format created.'
      redirect_to event_staff_session_formats_path(@event)
    else
      flash[:danger] = 'Unable to create session format.'
      render :new
    end
  end

  def update
    if @session_format.update_attributes(session_format_params)
      flash[:info] = 'Session format updated.'
      redirect_to event_staff_session_formats_path(@event)
    else
      flash[:danger] = 'Unable to update session format.'
      render :edit
    end
  end

  def destroy
    if @session_format.destroy
      flash[:info] = 'Session format destroyed.'
    else
      flash[:danger] = 'Unable to destroy session format.'
    end

    redirect_to event_staff_session_formats_path(@event)
  end

  private

  def set_session_format
    @session_format = @event.session_formats.find(params[:id])
  end

  def session_format_params
    params.require(:session_format)
        .permit(:id, :name, :description, :event_id, :duration, :public)
  end

end
