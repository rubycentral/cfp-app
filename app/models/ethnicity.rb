class Ethnicity < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_many :users

  def label
    "#{name}: #{description}"
  end
end
