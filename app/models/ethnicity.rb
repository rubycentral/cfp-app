class Ethnicity < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_many :speakers

  def to_label
    "#{name}: #{description}"
  end
end
