class Staff::Grids::BulkTimeSlotsController < Staff::ApplicationController
  include ScheduleSupport

  def new
    @bulk = BulkTimeSlot.new(day: params[:day])
    render partial: 'create_dialog', locals: {bulk: @bulk}
  end

  def preview
    @bulk = BulkTimeSlot.new(bulk_time_slot_params)

    unless @bulk.valid?
      render :create and return
    end

    slots = @bulk.build_time_slots
    @schedule = Schedule.new(current_event)
    @schedule.add_preview_slots(slots)

    respond_to do |format|
      format.turbo_stream
    end
  end

  def cancel
    @schedule = Schedule.new(current_event)
    respond_to do |format|
      format.turbo_stream
    end
  end

  def edit
    @bulk = BulkTimeSlot.new(bulk_time_slot_params)
    render partial: 'create_dialog', locals: {bulk: @bulk}
  end

  def create
    @bulk = BulkTimeSlot.new(bulk_time_slot_params)
    @bulk.create_time_slots
    @schedule = Schedule.new(current_event)

    respond_to do |format|
      format.turbo_stream { flash.now[:info] = 'Time slots created successfully.' }
      format.json { render json: { slots: current_event.time_slots }, status: :ok }
    end
  rescue StandardError => e
    render json: { slots: current_event.time_slots, errors: ["An error occured when attempting to bulk create"] }, status: 500
  end

  private

  def bulk_time_slot_params
    params.require(:bulk_time_slot).permit(:day, :duration, {rooms: []}, :start_times)
        .merge(event: current_event)
  end
end
