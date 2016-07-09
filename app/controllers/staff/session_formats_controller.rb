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
    session_formate = @event.session_formates.build(session_formate_params)
    unless session_formate.save
      flash.now[:warning] = "There was a problem saving your session formate"
    end

    respond_to do |format|
      format.js do
        render locals: { session_formate: session_formate }
      end
    end
  end

  def update
    session_formate = SessionFormat.find(params[:id])
    session_formate.update_attributes(session_formate_params)
    respond_to do |format|
      format.js do
        render locals: { session_formate: session_formate }
      end
    end
  end

  def destroy
    session_formate = @event.session_formates.find(params[:id]).destroy

    flash.now[:info] = "This session formate has been deleted."
    respond_to do |format|
      format.js do
        render locals: { session_formate: session_formate }
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
