class Website < ApplicationRecord
  belongs_to :event
  has_many :pages, dependent: :destroy

  has_many :session_formats, through: :event
  has_many :session_format_configs
  accepts_nested_attributes_for :session_format_configs

  has_one_attached :logo
  has_one_attached :background

  DEFAULT = 'default'.freeze

  def self.domain_match(domain)
    where(arel_table[:domains].matches("%#{(domain)}"))
  end
end

# == Schema Information
#
# Table name: websites
#
#  id                   :bigint(8)        not null, primary key
#  event_id             :bigint(8)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  theme                :string           default("default")
#  domains              :string
#  city                 :string
#  location             :text
#  prospectus_link      :string
#  twitter_handle       :string
#  directions           :string
#  footer_categories    :string           default([]), is an Array
#  footer_about_content :text
#  footer_copyright     :string
#  facebook_url         :string
#  instagram_url        :string
#  navigation_links     :string           default([]), is an Array
#
# Indexes
#
#  index_websites_on_event_id  (event_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#
