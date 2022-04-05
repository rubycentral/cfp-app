class Page < ApplicationRecord
  belongs_to :website

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
