class Sponsor < ApplicationRecord
  belongs_to :event

  has_one_attached :primary_logo
  has_one_attached :footer_logo
  has_one_attached :banner_ad

  TIERS = ['platinum', 'gold', 'silver', 'bronze', 'other', 'supporter']
end
