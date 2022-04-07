class PagesController < ApplicationController
  def show
    @page = current_website.pages.find_by(slug: params[:page] || 'home')
    render layout: "themes/#{current_website.theme}"
  end
end
