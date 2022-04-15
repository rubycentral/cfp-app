class ScheduleController < ApplicationController
  include WebsiteScheduleHelper
  before_action :require_event

  def show
    time_slots = current_event.time_slots.grid_order
                                         .includes(:room, program_session: { proposal: {speakers: :user }})
    @schedule = time_slots.map {|slot| TimeSlotSerializer.new(slot).as_json }
    render layout: "themes/#{current_website.theme}"
  end
end