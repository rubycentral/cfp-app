class WebsiteDecorator < ApplicationDecorator
  delegate_all

  def name
    event.name
  end

  def date_range
    event.date_range
  end

  def event
    @event ||= object.event.decorate
  end

  def location
    h.simple_format(object.location)
  end

  def contact_email
    event.contact_email
  end

  def closes_at
    event.closes_at(:month_day_year)
  end

  def banner_sponsors
    event.sponsors.published.with_banner_ad
  end

  def sponsors_in_footer
    event.sponsors.published.with_footer_image.order_by_tier
  end

  def navigation_page_names_and_slugs
    pages.navigatable.pluck(:name, :slug)
  end
end
