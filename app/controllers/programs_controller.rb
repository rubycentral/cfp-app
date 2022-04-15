class ProgramsController < ApplicationController
  before_action :require_website

  def show
    @program_sessions = current_website.event.program_sessions.live
    render layout: "themes/#{current_website.theme}"
  end
end
