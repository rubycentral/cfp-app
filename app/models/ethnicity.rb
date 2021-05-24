class Ethnicity < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_many :speakers

  # Racial categories according to the Census
  RACIAL_CATEGORIES = [
    'American Indian or Alaska Native', 'Asian', 'Black or African American',
    'Hispanic or Latino', 'Native Hawaiian or Other Pacific Islander', 'Native American or Alaskan Natives',
    'Non-Hispanic White', 'Two or more races', 'Other'
  ].freeze
  
 def to_label 
    "#{name}: #{description}"
  end
end
