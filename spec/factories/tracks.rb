FactoryBot.define do
  factory :track do
    name { Faker::Superhero.name }
    description { Faker::Company.catch_phrase }
  end
end
