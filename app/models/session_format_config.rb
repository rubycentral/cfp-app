class SessionFormatConfig < ApplicationRecord
  belongs_to :website
  belongs_to :session_format

  scope :displayed, ->{ where(display: true) }
  scope :in_order, ->{ order(:position) }

  def slug
    session_format.name.parameterize.pluralize
  end
end

# == Schema Information
#
# Table name: session_format_configs
#
#  id                :bigint(8)        not null, primary key
#  website_id        :bigint(8)
#  session_format_id :bigint(8)
#  position          :integer
#  name              :string
#  display           :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_session_format_configs_on_session_format_id  (session_format_id)
#  index_session_format_configs_on_website_id         (website_id)
#
# Foreign Keys
#
#  fk_rails_...  (session_format_id => session_formats.id)
#  fk_rails_...  (website_id => websites.id)
#
