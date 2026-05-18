class Staff::TimeSlotsController < Staff::ApplicationController
  include ScheduleSupport

  before_action :set_time_slot, only: [:edit, :update, :destroy]

  helper_method :time_slot_decorated

  private decorates_assigned :time_slots, with: Staff::TimeSlotDecorator

  def index
    @time_slots = current_event.time_slots.grid_order
                      .includes(:room, program_session: [{speakers: :user}, :track])

    respond_to do |format|
      format.html
      format.csv { send_data time_slots.to_csv }
      # note: we don't use the decorator with the json output
      format.json { render_json(@time_slots, filename: json_filename) }
    end
  end

  def new
    if session[:sticky_time_slot]
      @time_slot = current_event.time_slots.build(session[:sticky_time_slot])
    else
      start_time = TimeSlot::DEFAULT_TIME
      end_time = start_time + TimeSlot::DEFAULT_DURATION.minutes
      @time_slot = current_event.time_slots.build(start_time: start_time, end_time: end_time)
    end

    render layout: false
  end

  def create
    @save_and_add = params[:button] == 'save_and_add'
    @time_slot = current_event.time_slots.build(time_slot_params)

    if @time_slot.save
      flash.now[:info] = 'Time slot added.'
      session[:sticky_time_slot] = {
        conference_day: @time_slot.conference_day,
        start_time: @time_slot.start_time,
        end_time: @time_slot.end_time,
        room_id: @time_slot.room ? @time_slot.room.id : nil
      }
      @time_slot.reload
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to event_staff_schedule_time_slots_path(current_event) }
      end
    else
      flash.now[:danger] = "There was a problem creating this time slot."
      respond_to do |format|
        format.turbo_stream { render :create_error, status: :unprocessable_entity }
        format.html { redirect_to event_staff_schedule_time_slots_path(current_event) }
      end
    end
  end

  def edit
    render layout: false
  end

  def update
    if @time_slot.update(time_slot_params)
      flash.now[:info] = "Time slot updated."
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to event_staff_schedule_time_slots_path(current_event) }
      end
    else
      flash.now[:danger] = "There was a problem saving this time slot."
      respond_to do |format|
        format.turbo_stream { render :update_error, status: :unprocessable_entity }
        format.html { redirect_to event_staff_schedule_time_slots_path(current_event) }
      end
    end
  end

  def destroy
    @time_slot.destroy
    flash.now[:info] = 'Time slot removed.'
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to event_staff_schedule_time_slots_path(current_event) }
    end
  end

  private

  def time_slot_params
    params.require(:time_slot).permit(:conference_day, :room_id, :start_time, :end_time, :program_session_id, :sponsor_id, :title, :track_id, :presenter, :description)
  end

  def set_time_slot
    @time_slot = current_event.time_slots.find(params[:id])
  end

  def time_slot_decorated
    @time_slot_decorated ||= Staff::TimeSlotDecorator.decorate(@time_slot)
  end

  def json_filename
    "#{current_event.slug}-schedule-#{Time.current.to_fs(:db_just_date)}.json"
  end
end
