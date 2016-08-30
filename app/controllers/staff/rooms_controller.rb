class Staff::RoomsController < Staff::SchedulesController

  before_action :set_time_slots, only: [:update, :destroy]
  before_action :set_room, only: [:update, :destroy]

  def create
    room = @event.rooms.build(room_params)
    if room.save
      flash.now[:success] = "#{room.name} has been added to rooms."
    else
      flash.now[:danger] = "There was a problem saving your room, #{room.errors.full_messages.join(", ")}"
    end
    respond_to do |format|
      format.js do
        render locals: { room: room }
      end
    end
  end

  def update
    if @room.update_attributes(room_params)
      flash.now[:success] = "#{@room.name} has been updated."
    else
      flash.now[:danger] = "There was a problem updating your room, #{@room.errors.full_messages.join(", ")}."
    end
    respond_to do |format|
      format.js do
        render locals: { room: @room }
      end
    end
  end

  def destroy
    if @room.destroy
      flash.now[:success] = "#{@room.name} has been deleted."
    else
      flash.now[:danger] = "There was a problem deleting #{@room.name}."
    end
    respond_to do |format|
      format.js do
        render locals: { room: @room }
      end
    end
  end

  private

  def room_params
    params.require(:room).permit(:name, :room_number, :level, :address, :capacity, :grid_position)
  end

  def set_room
    @room = @event.rooms.find(params[:id])
  end

end
