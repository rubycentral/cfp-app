class Website < ApplicationRecord
  enum :caching, { off: 'off', automatic: 'automatic', manual: 'manual' }, prefix: true

  belongs_to :event
  has_many :time_slots, through: :event
  has_many :sponsors, through: :event
  has_many :program_sessions, through: :event
  has_many :pages, dependent: :destroy
  has_many :fonts, class_name: 'Website::Font', dependent: :destroy
  has_many :contents, class_name: 'Website::Content', dependent: :destroy
  has_one :meta_data, class_name: 'Website::MetaData', dependent: :destroy

  has_many :session_formats, through: :event
  has_many :session_format_configs

  accepts_nested_attributes_for :fonts,
    reject_if: ->(font) { font['name'].blank? && font['file'].blank? },
    allow_destroy: true
  accepts_nested_attributes_for :contents, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :meta_data
  accepts_nested_attributes_for :session_format_configs

  has_one_attached :logo
  has_one_attached :background
  has_one_attached :favicon

  around_update :purge_cache, if: :caching_automatic?

  DEFAULT = 'default'.freeze

  def self.domain_match(domain)
    where(arel_table[:domains].matches("%#{domain}%"))
  end

  def manual_purge
    purge_cache { save }
  end

  def purge_cache
    self.purged_at = Time.current
    yield
    FastlyService.service&.purge_by_key(event.slug)
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
