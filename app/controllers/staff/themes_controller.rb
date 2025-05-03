class Staff::ThemesController < Staff::ApplicationController
  before_action :require_website
  before_action :enable_website_subnav

  def show
    render template: "staff/pages/themes/#{current_website.theme}/#{theme_params['name']}", layout: "themes/#{current_website.theme}"
  end

  def theme_params
    params.permit(:name)
  end
end
