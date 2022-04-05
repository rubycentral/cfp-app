class Staff::PagesController < Staff::ApplicationController
  def index
    @pages = current_website.pages
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

  private

  def page_params
    params.require(:page).permit(:name, :slug, :body)
  end
end
