class ProgramsController < ApplicationController
  before_action :require_event
 
  def index
    @program_session = current_event.program_sessions
    render layout: "themes/#{current_website.theme}"
  end
end
 