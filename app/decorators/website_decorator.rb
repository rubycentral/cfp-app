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

  def categorized_footer_pages
    pages.in_footer
      .select(:footer_category, :name, :slug)
      .group_by(&:footer_category)
      .sort_by { |category, _| footer_categories.index(category) }
  end

  def twitter_url
    "https://twitter.com/#{object.twitter_handle}"
  end

  def register_page
    pages.published.find_by(slug: 'register')
  end

  def background_style
    return {} unless background.attached?

    { style: "background-image: url('#{h.url_for(background)}');" }
  end
end
