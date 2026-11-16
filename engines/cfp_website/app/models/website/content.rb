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
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  html       :text
#  name       :string
#  placement  :string           default("head"), not null
#  updated_at :datetime         not null
#  website_id :integer
#
# Indexes
#
#  index_website_contents_on_website_id  (website_id)
#
