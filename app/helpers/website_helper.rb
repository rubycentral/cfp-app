module WebsiteHelper
  def website_event_slug
    params[:slug] || (@older_domain_website && @older_domain_website.event.slug)
  end
end
