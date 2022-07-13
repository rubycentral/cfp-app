module PageHelper
  TAGS = {
    "<sponsors-banner-adds></sponsors-banner-adds>" => "sponsors/banner_ads", #DEPRECATED spelling mistake
    "<sponsors-banner-ads></sponsors-banner-ads>" => "sponsors/banner_ads",
    "<sponsors-footer></sponsors-footer>" => "sponsors/sponsors_footer",
    /(<logo-image.*><\/logo-image>)/ => :logo_image,
    "background-image-style-url" => :background_style,
  }

  def embed(body)
    body.tap do |body|
      TAGS.each do |tag, template|
        body.gsub!(tag) do
          args = tag.is_a?(Regexp) ? extract($1) : {}
          case template
          when String
            render(**args.merge(template: template, layout: false))
          when Symbol
            send(template, **args)
          end
        end
      end
    end.html_safe
  end

  def extract(tag)
    fragment = Nokogiri::HTML.fragment(tag)
    tag_name = fragment.children.first.name
    fragment.at(tag_name).to_h.symbolize_keys
  end

  def background_style
    current_website.background_style_html
  end

  def logo_image(args)
    resize_image_tag(current_website.logo, **args)
  end

  def tailwind_content
    return false if @include_tailwind

    @page&.tailwind_css&.html_safe
  end
end
