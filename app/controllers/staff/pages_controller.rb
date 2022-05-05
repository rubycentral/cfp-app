class Staff::PagesController < Staff::ApplicationController
  before_action :enable_website_subnav
  before_action :set_page, except: :index
  before_action :authorize_page, except: :index

  def index
    @pages = current_website.pages
    authorize(@pages)
  end

  def show
    @body = params[:preview] || @page.unpublished_body || ""
    render template: 'pages/show', layout: "themes/#{current_website.theme}"
  end

  def new; end

  def create
    if @page.update(page_params)
      flash[:success] = "#{@page.name} Page was successfully created."
      redirect_to event_staff_pages_path(current_event)
    else
      render :new
    end
  end

  def edit; end

  def update
    if @page.update(page_params)
      flash[:success] = "#{@page.name} Page was successfully updated."
      redirect_to event_staff_pages_path(current_event)
    else
      render :edit
    end
  end

  def preview; end

  def publish
    @page.update(published_body: @page.unpublished_body)
    flash[:success] = "#{@page.name} Page was successfully published."
    redirect_to event_staff_pages_path(current_event)
  end

  def promote
    Page.promote(@page)
    flash[:success] = "#{@page.name} Page was successfully promoted."
    redirect_to event_staff_pages_path(current_event)
  end

  def destroy
    @page.destroy
    flash[:success] = "#{@page.name} Page was successfully destroyed."
    redirect_to event_staff_pages_path(current_event)
  end

  private

  def set_page
    @page = if params[:id] && (params[:id] != Page::BLANK_SLUG)
              current_website.pages.find_by(slug: params[:id])
            else
              build_page
            end
  end

  def build_page
    if template = params[:page] && page_params[:template].presence
      Page.from_template(
        template,
        unpublished_body: render_to_string(
          "staff/pages/themes/#{current_website.theme}/#{template}",
          layout: false
        ),
        website: current_website
      )
    else
      current_website.pages.build
    end
  end

  def authorize_page
    authorize(@page)
  end

  def page_params
    params
      .require(:page)
      .permit(
        :template,
        :name,
        :slug,
        :hide_page,
        :hide_header,
        :hide_footer,
        :footer_category,
        :unpublished_body
      )
  end
end
