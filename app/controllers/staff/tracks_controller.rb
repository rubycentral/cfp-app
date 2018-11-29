class Staff::TracksController < Staff::ApplicationController

  before_action :set_track, only: [:edit, :update, :destroy]

  def index
    @tracks = current_event.tracks.sort_by_name
  end

  def new
    @track = Track.new
  end

  def edit
    respond_to do |format|
      format.js do
        render locals: { track: @track }
      end
    end
  end

  def create
    track = current_event.tracks.build(track_params)
    unless track.save
      flash.now[:danger] = "There was a problem saving your track, #{track.errors.full_messages.join(", ")}."
    end
    respond_to do |format|
      format.js do
        render locals: { track: track }
      end
    end
  end

  def update
    if @track.update_attributes(track_params)
      flash.now[:success] = "#{@track.name} has been updated." # changes to guildlines are invisible
    else
      flash.now[:danger] = "There was a problem updating your track, #{@track.errors.full_messages.join(", ")}."
    end
    respond_to do |format|
      format.js do
        render locals: { track: @track }
      end
    end
  end

  def destroy
    unless @track.destroy
      flash.now[:danger] = "There was a problem deleting the #{@track.name} track."
    end
    respond_to do |format|
      format.js do
        render locals: { track: @track }
      end
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
