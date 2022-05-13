class WebsiteDecorator < ApplicationDecorator
  delegate_all
  delegate :title, :author, :description, to: :meta_data

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
    end.sort_by { |_key, value| navigation_links.index(value) || 0 }.to_h
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

  def session_format_background_class(session_format)
    "session-format-bg-#{session_format_num(session_format)}"
  end

  def session_format_name(session_format)
    object.session_format_configs.find_by(session_format: session_format).name
  end

  def font_faces_css
    fonts.map do |font|
      <<~CSS
        @font-face {
          font-family: "#{font.name}";
          src: url('#{h.rails_storage_proxy_path(font.file)}');
        }
      CSS
    end.join("\n").html_safe
  end

  def font_root_css
    font_primary = fonts.primary.first
    font_secondary = fonts.secondary.first

    return "" unless font_primary || font_secondary
    <<~CSS.html_safe
      :root {
        #{"--sans-serif-font: '#{font_primary.name}' !important;" if font_primary}
        #{"--secondary-body-font: '#{font_secondary.name}' !important;" if font_secondary}
      }
    CSS
  end

  def head_content
    object.contents.for(Website::Content::HEAD).pluck(:html).join.html_safe
  end

  def footer_content
    object.contents.for(Website::Content::FOOTER).pluck(:html).join.html_safe
  end

  def meta_data
    @meta_data ||= object.meta_data || object.build_meta_data
  end

  def meta_image_url
    attachment = meta_data.image.attached? ? meta_data.image : logo
    h.polymorphic_url(attachment) if attachment.attached?
  end

  def website_title(page_title)
    [page_title, title].reject(&:blank?).join(" | ")
  end

  def favicon_url
    h.polymorphic_url(favicon) if favicon.attached?
  end
end
