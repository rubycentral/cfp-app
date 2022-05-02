module PageHelper
  TAGS = {
    "<sponsors-banner-adds></sponsors-banner-adds>" => "sponsors/banner_ads",
    "<sponsors-footer></sponsors-footer>" => "sponsors/sponsors_footer"
  }

  def embed(body)
    body.tap do |body|
      TAGS.each do |tag, template|
        body.gsub!(tag, render(template: template, layout: false))
      end
    end.html_safe
  end
end
