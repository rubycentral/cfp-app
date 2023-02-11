FactoryBot.define do
  factory :track do
    event { Event.first || FactoryBot.create(:event) }
    name { Faker::Superhero.name }
    description { Faker::Company.catch_phrase }
  end
end
