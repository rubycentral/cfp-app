class Staff::PagesController < Staff::ApplicationController
  before_action :require_website
  before_action :enable_website_subnav
  before_action :set_page, except: :index
  before_action :authorize_page, except: :index

  def index
    @pages = current_website.pages
    authorize(@pages)
  end

  def show
    @body = params[:preview] || @page.unpublished_body || ""
    @include_tailwind = true
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
    save_tailwind_page_content

    @page.update(published_body: @page.unpublished_body,
                 body_published_at: Time.current)
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

  def save_tailwind_page_content
    Puppeteer.launch(
      headless: true,
      args: ['--no-sandbox', '--disable-setuid-sandbox']
    ) do |browser|
      page = browser.pages.first || browser.new_page
      page.goto(root_url)
      cookies.each do |name, value|
        page.set_cookie(name: name, value: value)
      end
      page.goto(event_staff_page_url(current_event, @page), wait_until: 'domcontentloaded')
      css = page.query_selector_all('style').map do |style|
        style.evaluate('(el) => el.textContent')
      end.detect { |text| text.match("tailwindcss") }
      html = "<style>#{css}</style>"

      content = @page.contents.find_or_initialize_by(name: Page::TAILWIND)
      content.update!(placement: Website::Content::HEAD, html: html)
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

  def require_website
    return if current_website

    redirect_to new_event_staff_website_path(current_event),
      alert: "Please configure your website before attempting to create pages"
  end
end
