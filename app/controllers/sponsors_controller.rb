class SponsorsController < ApplicationController
  before_action :require_website
  before_action :load_sponsors

  def show
    render layout: "themes/#{current_website.theme}"
  end
end
