class Website < ApplicationRecord
  belongs_to :event
  has_many :pages, dependent: :destroy

  has_one_attached :logo
  has_one_attached :background

  DEFAULT = 'default'.freeze

  def footer_categories=(values)
    categories = values.is_a?(String) ? values.split(',') : values
    self[:footer_categories] = categories
  end

  def self.domain_match(domain)
    where(arel_table[:domains].matches("%#{(domain)}"))
  end
end

# == Schema Information
#
# Table name: websites
#
#  id                :bigint(8)        not null, primary key
#  event_id          :bigint(8)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  theme             :string           default("default")
#  domains           :string
#  city              :string
#  location          :text
#  prospectus_link   :string
#  twitter_handle    :string
#  directions        :string
#  footer_categories :string           is an Array
#
# Indexes
#
#  index_websites_on_event_id  (event_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#
