class Staff::TracksController < Staff::ApplicationController
  before_action :set_track, only: [:edit, :update, :destroy]

  def index
    @tracks = current_event.tracks.sort_by_name
  end

  def new
    @track = Track.new
    render layout: false
  end

  def edit
    render layout: false
  end

  def create
    @track = current_event.tracks.build(track_params)
    if @track.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to config_event_staff_path(current_event) }
      end
    else
      flash.now[:danger] = "There was a problem saving your track, #{@track.errors.full_messages.join(", ")}."
      respond_to do |format|
        format.turbo_stream { render :create_error, status: :unprocessable_entity }
        format.html { render :new, layout: false, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @track.update(track_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to config_event_staff_path(current_event) }
      end
    else
      flash.now[:danger] = "There was a problem updating your track, #{@track.errors.full_messages.join(", ")}."
      respond_to do |format|
        format.turbo_stream { render :update_error, status: :unprocessable_entity }
        format.html { render :edit, layout: false, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @track.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to config_event_staff_path(current_event), status: :see_other }
    end
  end

  private

  def set_track
    @track = current_event.tracks.find(params[:id])
  end

  def track_params
    params.require(:track).permit(:name, :description, :guidelines)
  end
end
