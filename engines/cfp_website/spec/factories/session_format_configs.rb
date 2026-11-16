FactoryBot.define do
  factory :session_format_config do
    website { Website.first || FactoryBot.create(:website) }
    session_format { FactoryBot.create(:session_format) }
    display { true }
    name { session_format.name }

    trait :custom_name do
      name { "Custom Name" }
    end
  end
end
