class Staff::WebsitesController < Staff::ApplicationController
  before_action :enable_website_subnav

  def edit
    website
  end

  def update
    if website.update(website_params)
      flash[:success] = "#{current_event.name} website was successfully updated."
    end
    redirect_to edit_event_staff_website_path(current_event)
  end

  private

  def website
    @website ||= (current_website || current_event.build_website)
  end

  def website_params
    params.require(:website)
      .permit(
        :logo,
        :domains,
        :theme,
        :body_background_color,
        :nav_background_color,
        :nav_text_color,
        :nav_link_hover,
        :main_content_background,
        :sans_serif_font,
    )
  end
end
