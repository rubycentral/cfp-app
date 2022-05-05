class Sponsor < ApplicationRecord
  belongs_to :event

  has_one_attached :primary_logo
  has_one_attached :footer_logo
  has_one_attached :banner_ad

  validates :primary_logo, presence: true

  TIERS = ['platinum', 'gold', 'silver', 'bronze', 'other', 'supporter']

  scope :published, -> { where(published: true) }
  scope :with_footer_image, -> { joins(:footer_logo_attachment) }
  scope :with_banner_ad, -> { joins(:banner_ad_attachment) }
  scope :order_by_tier, -> {
    order_case = "CASE tier"
    TIERS.each_with_index do |tier, index|
      order_case << " WHEN '#{tier}' THEN #{index}"
    end
    order_case << " END"
    order(Arel.sql(order_case))
  }

  def has_offer?
    offer_headline && offer_text && offer_url
  end
end

# == Schema Information
#
# Table name: sponsors
#
#  id             :bigint(8)        not null, primary key
#  event_id       :bigint(8)
#  name           :string
#  tier           :string
#  published      :boolean
#  url            :string
#  other_title    :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  description    :text
#  offer_headline :string
#  offer_text     :text
#  offer_url      :string
#
# Indexes
#
#  index_sponsors_on_event_id  (event_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#
