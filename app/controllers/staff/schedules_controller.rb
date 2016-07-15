class Staff::SchedulesController < Staff::ApplicationController
  decorates_assigned :time_slots

  protected

  def set_time_slots
    @time_slots =
      @event.time_slots.includes(:room, program_session: { proposal: {speakers: :user }})
  end
end
