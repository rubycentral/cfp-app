class Staff::Grids::TimeSlotsController < Staff::ApplicationController
  include ScheduleSupport

  before_action :set_time_slot, only: [:edit, :update]

  helper_method :time_slot_decorated

  def edit
  end

  def update
    if @time_slot.update_attributes(time_slot_params)
      flash.now[:info] = "Time slot updated."
    else
      flash.now[:danger] = "There was a problem saving this time slot."
    end

    respond_to do |format|
      format.js
    end
  end

  private

  def time_slot_params
    params.require(:time_slot).permit(:conference_day, :room_id, :start_time, :end_time, :program_session_id, :title, :track_id, :presenter, :description)
  end

  def set_time_slot
    @time_slot = current_event.time_slots.find(params[:id])
  end

  def time_slot_decorated
    @time_slot_decorated ||= Staff::TimeSlotDecorator.decorate(@time_slot)
  end

end
