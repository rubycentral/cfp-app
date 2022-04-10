class ProgramsController < ApplicationController
  before_action :require_event

  def index
    @program_sessions = current_event.program_sessions.live
    render layout: "themes/#{current_website.theme}"
  end
end
