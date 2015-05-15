class Organizer::RoomsController < Organizer::SchedulesController

  before_filter :set_sessions, only: [:update, :destroy]

  def create
    room = @event.rooms.build(room_params)
    unless room.save
      flash.now[:warning] = "There was a problem saving your room"
    end

    respond_to do |format|
      format.js do
        render locals: { room: room }
      end
    end
  end

  def update
    room = Room.find params[:id]
    room.update_attributes(room_params)

    respond_to do |format|
      format.js do
        render locals: { room: room }
      end
    end
  end

  def destroy
    room = @event.rooms.find(params[:id]).destroy

    flash.now[:info] = "This room has been deleted."
    respond_to do |format|
      format.js do
        render locals: { room: room }
      end
    end
  end

  private

  def room_params
    params.require(:room).permit(:name, :room_number, :level, :address, :capacity, :grid_position)
  end

end
