class PagesController < ApplicationController
  before_action :require_website, only: :show
  before_action :require_page, only: :show

  def current_styleguide
  end

  def show
    @body = @page.published_body
    render layout: "themes/#{current_website.theme}"
  end

  private

  def require_page
    @page = current_website.pages.published.find_by(page_conditions)
    unless @page
      @body = "Page Not Found"
      render layout: "themes/#{current_website.theme}" and return
    end
  end

  def page_conditions
    landing_page_request? ? { landing: true } : { slug: page_param }
  end

  def page_param
    params[:domain_page_or_slug] || params[:page]
  end

  def landing_page_request?
    page_param.nil? || @older_domain_website
  end
end
