module WebsiteHelper
  def website_event_slug
    params[:slug] || (@older_domain_website && @older_domain_website.event.slug)
  end

  def font_file_label(font)
    "File".tap do |label|
      label.concat(" (Current File: #{font.file.filename.to_s})") if font.file.attached?
    end
  end
end
