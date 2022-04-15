class Page < ApplicationRecord
  belongs_to :website

  scope :published, -> { where.not(published_body: nil) }

  validates :name, :slug, presence: true

  def to_param
    slug
  end

  def self.promote(page)
    transaction do
      page.website.pages.update(landing: false)
      page.update(landing: true)
    end
  end
end

# == Schema Information
#
# Table name: pages
#
#  id               :bigint(8)        not null, primary key
#  name             :string
#  slug             :string
#  website_id       :bigint(8)
#  published_body   :text
#  unpublished_body :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_pages_on_website_id  (website_id)
#
# Foreign Keys
#
#  fk_rails_...  (website_id => websites.id)
#
