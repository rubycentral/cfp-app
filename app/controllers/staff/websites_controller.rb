class Staff::WebsitesController < Staff::ApplicationController
  before_action :set_website
  before_action :authorize_website
  before_action :enable_website_subnav

  def new; end

  def create
    @website.update(website_params)

    flash[:success] = "Website was successfully created."
    redirect_to edit_event_staff_website_path(current_event)
  end

  def edit; end

  def update
    @website.update(website_params)

    flash[:success] = "Website was successfully updated."
    redirect_to edit_event_staff_website_path(current_event)
  end

  private

  def set_website
    @website = (current_event.website || current_event.build_website).decorate
  end

  def authorize_website
    authorize(@website)
  end

  def website_params
    params
      .require(:website)
      .permit(
        :logo,
        :background,
        :city,
        :location,
        :directions,
        :prospectus_link,
        :domains,
        :footer_about_content,
        :footer_copyright,
        :twitter_handle,
        :facebook_url,
        :instagram_url,
        :head_content,
        footer_categories: [],
        navigation_links: [],
        session_format_configs_attributes: [
          :id, :name, :display, :position, :session_format_id
        ],
        fonts_attributes: [
          :id, :name, :file, :primary, :secondary, :_destroy
        ],
        contents_attributes: [
          :id, :name, :html, :placement, :_destroy
        ],
    )
  end
end
