class Website < ApplicationRecord
  belongs_to :event
  has_many :pages
end

# == Schema Information
#
# Table name: websites
#
#  id         :bigint(8)        not null, primary key
#  event_id   :bigint(8)
#  phase      :string
#  theme      :string           default("default")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_websites_on_event_id  (event_id)
#
