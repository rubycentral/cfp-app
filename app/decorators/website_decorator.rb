class WebsiteDecorator < ApplicationDecorator
  delegate_all

  DEFAULT_LINKS = {
    'Schedule' => 'schedule',
    'Program' => 'program',
    'Sponsors' => 'sponsors',
  }.freeze

  def name
    event.name
  end

  def date_range
    event.date_range
  end

  def event
    @event ||= object.event.decorate
  end

  def formatted_location
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

  def categorized_footer_pages
    pages.in_footer
      .select(:footer_category, :name, :slug)
      .group_by(&:footer_category)
      .sort_by { |category, _| footer_categories.index(category) || 1_000 }
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

  def session_format_configs
    event.session_formats.map.with_index do |session_format, index|
      SessionFormatConfig.find_or_initialize_by(session_format: session_format) do |config|
        config.name = session_format.name
        config.position = index + 1
      end
    end.sort_by(&:position)
  end

  def displayed_session_formats
    object.session_format_configs.displayed
  end

  def default_session_slug
    object.session_format_configs.displayed.in_order.first.slug
  end

  def link_options
    @link_options ||= pages.published.pluck(:name, :slug)
      .each_with_object(DEFAULT_LINKS.dup) do |(name, slug), memo|
      memo[name] = slug
    end
  end

  def tracks
    event.tracks
  end

  def track_num(track)
    tracks.index(track) + 1
  end

  def track_background(track)
    "bg-track-#{track_num(track)}"
  end

  def session_format_num(session_format)
    session_formats.index(session_format) + 1
  end

  def session_format_tag_class(session_format)
    "session-format-tag-#{session_format_num(session_format)}"
  end

  def session_format_name(session_format)
    object.session_format_configs.find_by(session_format: session_format).name
  end
end
