class Staff::PagesController < Staff::ApplicationController
  before_action :enable_website_subnav

  def index
    @pages = current_website.pages
  end

  def show
    @body = current_website.pages.find_by(slug: params[:id]).unpublished_body
    render template: 'pages/show', layout: "themes/#{current_website.theme}"
  end

  def preview
    @page = current_website.pages.find_by(slug: params[:id])
  end

  def new
    @page = current_website.pages.build
  end

  def create
    @page = current_website.pages.create(page_params)
    flash[:success] = "#{@page.name} was successfully updated."
    redirect_to event_staff_pages_path(current_event, @page)
  end

  def edit
    @page = current_website.pages.find_by(slug: params[:id])
  end

  def update
    @page = current_website.pages.find_by(slug: params[:id])
    @page.update(page_params)
    flash[:success] = "#{@page.name} was successfully updated."
    redirect_to event_staff_pages_path(current_event, @page)
  end

  def publish
    @page = current_website.pages.find_by(slug: params[:id])
    @page.update(published_body: @page.unpublished_body)
    flash[:success] = "#{@page.name} was successfully published."
    redirect_to event_staff_pages_path(current_event, @page)
  end

  private

  def page_params
    params.require(:page).permit(:name, :slug, :unpublished_body)
  end
end
