FactoryBot.define do
  sequence :speaker_name do |n|
    "Speaker Name #{n}"
  end

  sequence :speaker_email do |n|
    "email#{n}@factory.com"
  end

  factory :speaker do
    user
    event { Event.first || FactoryBot.create(:event) }
    bio { "Speaker bio" }

    trait :with_name do
      speaker_name
    end
    trait :with_email do
      speaker_email
    end
  end
end
