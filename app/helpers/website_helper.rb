module WebsiteHelper
  DOCS_PAGE = "https://github.com/rubycentral/cfp-app/blob/main/docs/website_documentation.md".freeze
  def website_event_slug
    params[:slug] || (@older_domain_website && @older_domain_website.event.slug)
  end

  def font_file_label(font)
    "File".tap do |label|
      label.concat(" (Current File: #{font.file.filename.to_s})") if font.file.attached?
    end
  end

  def legend_with_docs(title)
    content_tag("legend", class: "fieldset-legend") do
      concat(title)
      concat(link_to_docs(title.parameterize))
    end
  end

  def link_to_docs(anchor)
    link_to(DOCS_PAGE + "##{anchor}", target: "_blank") do
      content_tag('i', nil, class: 'bi bi-question-circle')
    end
  end
end
