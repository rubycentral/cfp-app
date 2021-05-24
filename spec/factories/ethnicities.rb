FactoryBot.define do
  factory :ethnicity do
    name { 'Other' }

    trait :white do
      name { "White" }
      description { "A person having origins in any of the original peoples of Europe, the Middle East, or North Africa." }
    end

  end
end
