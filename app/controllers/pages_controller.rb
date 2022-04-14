class PagesController < ApplicationController
  def current_styleguide
  end

  def show
    page = current_website.pages.published.find_by!(slug: params[:page])
    @body = page.published_body
    render layout: "themes/#{current_website.theme}"
  rescue ActiveRecord::RecordNotFound
    redirect_to '/404'
  end
end
