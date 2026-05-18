class Staff::Grids::TimeSlotsController < Staff::ApplicationController
  include ScheduleSupport
  protect_from_forgery except: :edit
  before_action :set_time_slot, only: [:edit, :update]

  helper_method :time_slot_decorated

  def edit
    render partial: 'edit_dialog', locals: {time_slot: time_slot_decorated, event: current_event}
  end

  def update
    @session_assignment_only = time_slot_params.keys == ['program_session_id']
    respond_to do |format|
      if @time_slot.update(time_slot_params)
        format.turbo_stream { flash.now[:info] = "Time slot updated." }
        format.html { flash.now[:info] = "Time slot updated." }
      else
        format.turbo_stream do
          flash.now[:danger] = "There was a problem saving this time slot."
          render :update_error, status: :unprocessable_entity
        end
        format.html { flash.now[:danger] = "There was a problem saving this time slot." }
      end
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
