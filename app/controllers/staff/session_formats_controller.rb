class Staff::SessionFormatsController < Staff::ApplicationController
  before_action :set_session_format, only: [:edit, :update, :destroy]

  def index
    @session_formats = @event.session_formats
  end

  def new
    @session_format = SessionFormat.new
    render layout: false
  end

  def edit
    render layout: false
  end

  def create
    @session_format = @event.session_formats.build(session_format_params)
    if @session_format.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to event_staff_config_path(current_event) }
      end
    else
      flash.now[:danger] = "There was a problem saving your session format, #{@session_format.errors.full_messages.join(", ")}."
      respond_to do |format|
        format.turbo_stream { render :create_error, status: :unprocessable_entity }
        format.html { render :new, layout: false, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @session_format.update(session_format_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to event_staff_config_path(current_event) }
      end
    else
      flash.now[:danger] = "There was a problem updating your session format, #{@session_format.errors.full_messages.join(", ")}."
      respond_to do |format|
        format.turbo_stream { render :update_error, status: :unprocessable_entity }
        format.html { render :edit, layout: false, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @session_format.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to event_staff_config_path(current_event), status: :see_other }
    end
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
