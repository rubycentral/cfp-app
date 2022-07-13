class Website::Content < ApplicationRecord
  PLACEMENTS = [
    HEAD = "head",
    FOOTER = "footer",
  ].freeze

  belongs_to :contentable, polymorphic: true

  scope :for, -> (placement) { where(placement: placement) }
  scope :for_page, -> (slug) { where(name: slug) }
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
