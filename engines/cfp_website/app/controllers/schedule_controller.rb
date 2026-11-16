class ScheduleController < ApplicationController
  include WebsiteScheduleHelper
  after_action :set_cache_headers, only: :show

  private decorates_assigned :schedule, with: Staff::TimeSlotDecorator

  def show
    @schedule = current_website.time_slots.grid_order
      .includes(:room, program_session: { proposal: {speakers: :user}})
    render layout: "themes/#{current_website.theme}"
  end
end
