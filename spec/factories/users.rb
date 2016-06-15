FactoryGirl.define do
  sequence :email do |n|
    "email#{n}@factory.com"
  end

  factory :user do
    name "John Doe"
    email
    password "12345678"
    password_confirmation "12345678"
    demographics { { gender: "female" } }
    bio "A great Bio"

    trait :reviewer do
      after(:create) do |user|
        FactoryGirl.create(:participant, :reviewer, user: user)
      end
    end

    trait :organizer do
      after(:create) do |user|
        FactoryGirl.create(:participant, :organizer, user: user)
      end
    end

    factory :admin do
      admin true
    end

    factory :organizer, traits: [ :organizer ] do
      transient do
        event { build(:event) }
      end

      after(:create) do |user, evaluator|
        participant = user.organizer_participants.first
        participant.event = evaluator.event
        participant.event.save
      end
    end

    factory :reviewer, traits: [ :reviewer ] do
      transient do
        event { build(:event) }
      end

      after(:create) do |user, evaluator|
        participant = user.reviewer_participants.first
        participant.event = evaluator.event
        participant.save
      end
    end
  end
end
