class Staff::TimeSlotsController < Staff::SchedulesController

  before_action :set_time_slot, only: [:update, :destroy, :edit ]
  before_action :set_time_slots, only: :index

  helper_method :time_slot_decorator

  def new
    if session[:sticky_time_slot]
      @time_slot = @event.time_slots.build(session[:sticky_time_slot])
      @event = @event.decorate
    else
      date = DateTime.now.beginning_of_hour
      @time_slot = @event.time_slots.build(start_time: date, end_time: date)
      @event = @event.decorate
    end

    respond_to do |format|
      format.js
    end
  end

  def index
    @rooms = @event.rooms.by_grid_position
    respond_to do |format|
      format.html
      format.csv { send_data time_slots.to_csv }
      format.json { render_json(time_slots) }
    end
  end

  def create
    save_and_add = params[:button] == 'save_and_add'

    @time_slot = @event.time_slots.build(time_slot_params)

    f = save_and_add ? flash : flash.now
    if @time_slot.save
      f[:info] = "Time slot created."

      session[:sticky_time_slot] = {
        conference_day: @time_slot.conference_day,
        start_time: @time_slot.start_time,
        end_time: @time_slot.end_time,
        room_id: @time_slot.room ? @time_slot.room.id : nil
      }
    else
      f[:warning] = "There was a problem creating this time slot."
    end

    respond_to do |format|
      format.js do
        render locals: { save_and_add: save_and_add }
      end
    end
  end

  def edit
  end

  def update
    @time_slot.update_attributes(time_slot_params)
    flash.now[:info] = "Time slot updated."

    respond_to do |format|
      format.js
    end
  end

  def destroy
    time_slot_id = @time_slot.id
    @time_slot.destroy
    respond_to do |format|
      format.js do
        render locals: { time_slot_id: time_slot_id }
      end
    end
  end

private

  def time_slot_params
    params.require(:time_slot).permit(:conference_day, :start_time, :end_time, :title, :description, :presenter, :room_id, :program_session_id)
  end

  def set_time_slot
    @time_slot = TimeSlot.find(params[:id])
  end

  def time_slot_decorator
    @time_slot_decorator ||= @time_slot.decorate
  end
end
