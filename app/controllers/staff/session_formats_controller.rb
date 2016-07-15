class Staff::SessionFormatsController < Staff::ApplicationController
  before_action :set_session_format, only: [:edit, :update, :destroy]

  def index
    @session_formats = @event.session_formats
  end

  def new
    @session_format = SessionFormat.new
  end

  def edit
    respond_to do |format|
      format.js do
        render locals: { session_format: @session_format }
      end
    end
  end

  def create
    session_format = @event.session_formats.build(session_format_params)
    unless session_format.save
      flash.now[:warning] = "There was a problem saving your session format"
    end
    respond_to do |format|
      format.js do
        render locals: { session_format: session_format }
      end
    end
  end

  def update
    @session_format.update_attributes(session_format_params)
    respond_to do |format|
      format.js do
        render locals: { session_format: @session_format }
      end
    end
  end

  def destroy
    session_format = @event.session_formats.find(params[:id]).destroy
    flash.now[:info] = "This session format has been deleted."
    respond_to do |format|
      format.js do
        render locals: { session_format: session_format }
      end
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
