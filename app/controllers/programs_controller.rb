class ProgramsController < ApplicationController

  def show
    @program_sessions = current_event.program_sessions.live
    render layout: "themes/#{current_website.theme}"
  end
end
