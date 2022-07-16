class ProgramsController < ApplicationController
  before_action :require_website

  after_action :set_cache_headers, only: :show

  def show
    @program_sessions = current_website.program_sessions.live
    render layout: "themes/#{current_website.theme}"
  end
end
