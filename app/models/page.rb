class Page < ApplicationRecord
  belongs_to :website
  has_paper_trail only: %i[body published]
  has_rich_text :unpublished_body
  has_rich_text :published_body

  scope :published, -> {
    left_joins(:rich_text_published_body)
      .where.not(action_text_rich_texts: { id: nil })
  }

  def to_param
    slug
  end
end

# == Schema Information
#
# Table name: pages
#
#  id         :bigint(8)        not null, primary key
#  website_id :bigint(8)
#  name       :string
#  slug       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_pages_on_website_id  (website_id)
#
# Foreign Keys
#
#  fk_rails_...  (website_id => websites.id)
#
