class SponsorsController < ApplicationController
  before_action :require_website

  def show
    @sponsors_by_tier = Sponsor.published.order_by_tier.group_by(&:tier)
    render layout: "themes/#{current_website.theme}"
  end

  def sponsors_footer
    @sponsors_in_footer = Sponsor.published.with_footer_image.order_by_tier
    render layout: false
  end

  def banner_ads
    @sponsors_in_banner = Sponsor.published.with_banner_ad
    render layout: false
  end
end
