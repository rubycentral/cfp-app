FactoryBot.define do
  factory :sponsor do
    event
    name { Faker::Company.name }
  end
end
