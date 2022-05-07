class Website::Content < ApplicationRecord
  PLACEMENTS = [
    HEAD = "head",
    FOOTER = "footer",
  ].freeze

  belongs_to :website

  scope :for, -> (placement) { where(placement: placement) }
end

# == Schema Information
#
# Table name: website_contents
#
#  id         :bigint(8)        not null, primary key
#  html       :text
#  placement  :string           default("head"), not null
#  name       :string
#  website_id :bigint(8)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_website_contents_on_website_id  (website_id)
#
