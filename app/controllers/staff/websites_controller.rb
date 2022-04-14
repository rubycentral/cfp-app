class Staff::WebsitesController < Staff::ApplicationController
  before_action :set_website
  before_action :authorize_website
  before_action :enable_website_subnav

  def new; end

  def create
    @website.update(website_params)

    flash[:success] = "Website was successfully created."
    redirect_to event_staff_path(current_event)
  end

  def edit; end

  def update
    @website.update(website_params)

    flash[:success] = "Website was successfully updated."
    redirect_to event_staff_path(current_event)
  end

  private

  def set_website
    @website = current_event.website || current_event.build_website
  end

  def authorize_website
    authorize(@website)
  end

  def website_params
    params.require(:website).permit(:domains)
  end
end
