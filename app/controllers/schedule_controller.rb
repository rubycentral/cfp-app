class ScheduleController < ApplicationController
  include WebsiteScheduleHelper
  before_action :require_event

  decorates_assigned :schedule, with: Staff::TimeSlotDecorator

  def show
    @schedule = current_event.time_slots.grid_order.includes(:room, program_session: { proposal: {speakers: :user }})
    render layout: "themes/#{current_website.theme}"
  end
end