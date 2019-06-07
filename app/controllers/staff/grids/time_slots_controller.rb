class Staff::Grids::TimeSlotsController < Staff::ApplicationController
  include ScheduleSupport

  before_action :set_time_slot, only: [:edit, :update]

  helper_method :time_slot_decorated

  def edit
  end

  def update
    respond_to do |format|
      if @time_slot.update_attributes(time_slot_params)
        format.json { render json: update_response.merge(status: :ok) }
        format.html { flash.now[:info] = "Time slot updated." }
      else
        format.json { render json: update_response.merge({ errors: @time_slot.errors.full_messages, status: :bad_request }) }
        format.html { flash.now[:danger] = "There was a problem saving this time slot." }
      end
    end
  rescue StandardError => e
    render json: update_response.merge({errors: ["There was a problem updating this time slot."], status: 500})
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

  def update_response
    {
      unscheduled_count: current_event.program_sessions.unscheduled.count,
      total_count: current_event.program_sessions.count,
      day_counts: EventStats.new(current_event).schedule_counts,
      slots: current_event.time_slots,
      sessions: current_event.program_sessions,
      unscheduled_sessions: current_event.program_sessions.unscheduled,
    }
  end
end
