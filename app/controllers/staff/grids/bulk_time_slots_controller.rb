class Staff::Grids::BulkTimeSlotsController < Staff::ApplicationController
  include ScheduleSupport

  def new
    @bulk = BulkTimeSlot.new(day: params[:day])
  end

  def preview
    @bulk = BulkTimeSlot.new(bulk_time_slot_params)

    slots = @bulk.build_time_slots
    @schedule = Schedule.new(current_event)
    @schedule.add_preview_slots(slots)
  end

  def cancel
    @schedule = Schedule.new(current_event)
  end

  def edit
    @bulk = BulkTimeSlot.new(bulk_time_slot_params)
  end

  def create
    @bulk = BulkTimeSlot.new(bulk_time_slot_params)
    @bulk.create_time_slots
    @schedule = Schedule.new(current_event)
  end

  private

  def bulk_time_slot_params
    params.require(:bulk_time_slot).permit(:day, :duration, {rooms: []}, :start_times)
        .merge(event: current_event)
  end

end
