class ScheduleController < ApplicationController
  before_action :require_event

  def index
    @schedule = current_event.time_slots
    render layout: "themes/#{current_website.theme}"
  end
end