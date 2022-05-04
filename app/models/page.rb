class Page < ApplicationRecord
  TEMPLATES = {
    'splash' => { hide_header: true, hide_footer: true },
  }

  belongs_to :website

  scope :published, -> { where.not(published_body: nil).where(hide_page: false) }
  scope :navigatable, -> { published.where(hide_navigation: false) }
  scope :in_footer, -> { published.where.not(footer_category: [nil, ""]) }

  validates :name, :slug, presence: true
  validates :slug, uniqueness: { scope: :website_id }
  attr_accessor :template

  BLANK_SLUG = "0"

  def to_param
    persisted? ? slug : BLANK_SLUG
  end

  def self.promote(page)
    transaction do
      page.website.pages.update(landing: false)
      page.update(landing: true)
    end
  end

  def self.from_template(key, attrs)
    new(TEMPLATES[key].merge(template: key, name: key.titleize, slug: key, **attrs))
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
#  landing          :boolean          default(FALSE), not null
#  hide_header      :boolean          default(FALSE), not null
#  hide_footer      :boolean          default(FALSE), not null
#  hide_page        :boolean          default(FALSE), not null
#  hide_navigation  :boolean          default(FALSE), not null
#
# Indexes
#
#  index_pages_on_website_id  (website_id)
#
# Foreign Keys
#
#  fk_rails_...  (website_id => websites.id)
#
