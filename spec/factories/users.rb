FactoryGirl.define do
  sequence :email do |n|
    "email#{n}@factory.com"
  end

  factory :user do
    name "John Doe"
    email
    password "12345678"
    password_confirmation "12345678"
    bio "A great Bio"
    after(:create) { |user| user.confirm }

    trait :reviewer do
      name "John Doe Reviewer"
      after(:create) do |user|
        FactoryGirl.create(:event_teammate, :reviewer, user: user)
      end
    end

    trait :organizer do
      name "John Doe Organizer"
      after(:create) do |user|
        FactoryGirl.create(:event_teammate, :organizer, user: user)
      end
    end

    trait :program_team do
      name "John Doe Program Team"
      after(:create) do |user|
        FactoryGirl.create(:event_teammate, :program_team, user: user)
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
        event_teammate = user.organizer_event_teammates.first
        event_teammate.event = evaluator.event
        event_teammate.event.save
      end
    end

    factory :program_team, traits: [ :program_team ] do
      transient do
        event { build(:event) }
      end

      after(:create) do |user, evaluator|
        event_teammate = user.reviewer_event_teammates.first
        event_teammate.event = evaluator.event
        event_teammate.event.save
      end
    end

    factory :reviewer, traits: [ :reviewer ] do
      transient do
        event { build(:event) }
      end

      after(:create) do |user, evaluator|
        event_teammate = user.reviewer_event_teammates.first
        event_teammate.event = evaluator.event
        event_teammate.save
      end
    end
  end
end
