class Website::Font < ApplicationRecord
  belongs_to :website

  has_one_attached :file

  validates :file, :name, presence: true

  scope :primary, -> { where(primary: true) }
  scope :secondary, -> { where(secondary: true) }
end

# == Schema Information
#
# Table name: website_fonts
#
#  id         :integer          not null, primary key
#  name       :string
#  primary    :boolean
#  secondary  :boolean
#  website_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_website_fonts_on_website_id  (website_id)
#
