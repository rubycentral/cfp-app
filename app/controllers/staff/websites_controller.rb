class Staff::WebsitesController < Staff::ApplicationController
  before_action :set_website
  before_action :authorize_website
  before_action :enable_website_subnav

  def new; end

  def create
    if @website.update(website_params)
      flash[:success] = "Website was successfully created."
      redirect_to edit_event_staff_website_path(current_event)
    else
      flash[:warning] = "There were errors creating your website configuration"
      render :new
    end
  end

  def edit; end

  def update
    if @website.update(website_params)
      flash[:success] = "Website was successfully updated."
      redirect_to edit_event_staff_website_path(current_event)
    else
      flash[:warning] = "There were errors updating your website configuration"
      render :edit
    end
  end

  def purge
    @website.manual_purge

    flash[:success] = "Website was successfully purged."
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
        :favicon,
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
        :caching,
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
        meta_data_attributes: [
          :id, :title, :author, :description, :image
        ]
    )
  end
end
