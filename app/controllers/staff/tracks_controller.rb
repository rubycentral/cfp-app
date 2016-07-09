class Staff::TracksController < Staff::SchedulesController
  before_action :set_track, only: [:edit, :update, :destroy]

  def index
    @tracks = @event.tracks
  end

  def new
    @track = Track.new
  end

  def edit
  end

  def create
    track = @event.tracks.build(track_params)
    unless track.save
      flash.now[:warning] = "There was a problem saving your track"
    end

    respond_to do |format|
      format.js do
        render locals: { track: track }
      end
    end
  end

  def update
    track = Track.find(params[:id])
    track.update_attributes(track_params)
    respond_to do |format|
      format.js do
        render locals: { track: track }
      end
    end
  end

  def destroy
    track = @event.tracks.find(params[:id]).destroy

    flash.now[:info] = "This track has been deleted."
    respond_to do |format|
      format.js do
        render locals: { track: track }
      end
    end
  end

  private

  def set_track
    @track = @event.tracks.find(params[:id])
  end

  def track_params
    params.require(:track).permit(:name, :description, :guidelines)
  end

end
