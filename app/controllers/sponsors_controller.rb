class SponsorsController < ApplicationController
  before_action :require_website

  def show
    @sponsors_by_tier = Sponsor.published.order_by_tier.group_by(&:tier)
    render layout: "themes/#{current_website.theme}"
  end
end
