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
    @track = @event.tracks.build(track_params)

    if @track.save
      flash[:info] = 'Track created.'
      redirect_to event_staff_tracks_path(@event)
    else
      flash.now[:danger] = 'Unable to create track.'
      render :new
    end
  end

  def update
    if @track.update_attributes(track_params)
      flash[:info] = 'Track updated.'
      redirect_to event_staff_tracks_path(@event)
    else
      flash[:danger] = 'Unable to update track.'
      render :edit
    end
  end

  def destroy
    if @track.destroy
      flash[:info] = 'Track destroyed.'
    else
      flash[:danger] = 'Unable to destroy track.'
    end

    redirect_to event_staff_tracks_path(@event)
  end

  private

  def set_track
    @track = @event.tracks.find(params[:id])
  end

  def track_params
    params.require(:track).permit(:name, :description, :guidelines)
  end

end
