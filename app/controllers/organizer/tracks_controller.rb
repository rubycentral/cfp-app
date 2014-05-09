class Organizer::TracksController < Organizer::SchedulesController

  before_filter :set_sessions, only: :destroy

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

  def track_params
    params.require(:track).permit(:name)
  end

end
