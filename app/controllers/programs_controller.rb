class ProgramsController < ApplicationController
  def index
    @program_session = current_website.event.program_sessions
    render layout: "themes/#{current_website.theme}"
  end
end

