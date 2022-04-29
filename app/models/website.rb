class Website < ApplicationRecord
  belongs_to :event
  has_many :pages

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
#  id         :bigint(8)        not null, primary key
#  event_id   :bigint(8)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_websites_on_event_id  (event_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#
