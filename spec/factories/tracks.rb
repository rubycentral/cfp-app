# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :track do
    name Faker::Superhero.name
    description Faker::Company.catch_phrase
  end
end
