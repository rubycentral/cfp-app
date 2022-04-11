class PagesController < ApplicationController
  def show
    @page = current_website.pages.published.find_by(slug: params[:page] || 'home')
    @body = @page.published_body
    render layout: "themes/#{current_website.theme}"
  end
end
