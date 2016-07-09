class Staff::SessionFormatsController < Staff::ApplicationController
  before_action :set_session_formate, only: [:edit, :update, :destroy]

  def index
    @session_formates = @event.session_formates
  end

  def new
    @session_formate = SessionFormat.new(public: true)
  end

  def edit
  end

  def create
    session_format = @event.session_formats.build(session_format_params)
    unless session_format.save
      flash.now[:warning] = "There was a problem saving your session type"
    end
    respond_to do |format|
      format.js do
        render locals: { session_format: session_format }
      end
    end
  end

  def update
    session_format = SessionFormat.find(params[:id])
    session_format.update_attributes(session_format_params)
    respond_to do |format|
      format.js do
        render locals: { session_format: session_format }
      end
    end
  end

  def destroy
    session_format = @event.session_formats.find(params[:id]).destroy
    flash.now[:info] = "This session type has been deleted."
    respond_to do |format|
      format.js do
        render locals: { session_format: session_format }
      end
    end
  end

  private

  def set_session_formate
    @session_formate = @event.session_formates.find(params[:id])
  end

  def session_formate_params
    params.require(:session_formate)
        .permit(:id, :name, :description, :event_id, :duration, :public)
  end

end
