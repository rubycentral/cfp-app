class Sponsor < ApplicationRecord
  belongs_to :event

  TIERS = ['platinum', 'gold', 'silver', 'bronze', 'other', 'supporter']
end
