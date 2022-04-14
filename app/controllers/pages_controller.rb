class PagesController < ApplicationController
  before_action :require_website_page, only: :show

  def current_styleguide
  end

  def show
    @body = @page.published_body
    render layout: "themes/#{current_website.theme}"
  end

  private

  def require_website_page
    @page = current_website && current_website.pages.published.find_by(slug: params[:page])
    redirect_to not_found_path and return unless @page
  end
end
