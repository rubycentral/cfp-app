class SponsorsController < ApplicationController
  before_action :require_website

  after_action :set_cache_headers, only: :show

  def show
    @sponsors_by_tier = current_website.sponsors.published.order_by_tier.group_by(&:tier)
    render layout: "themes/#{current_website.theme}"
  end
end
