class Website::MetaData < ApplicationRecord
  belongs_to :website
  after_initialize :defaults

  has_one_attached :image

  def defaults
    self.title ||= website.event.name
    self.description ||= website.event.name
  end
end

# == Schema Information
#
# Table name: website_meta_data
#
#  id          :integer          not null, primary key
#  title       :string
#  author      :string
#  description :text
#  website_id  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_website_meta_data_on_website_id  (website_id)
#
