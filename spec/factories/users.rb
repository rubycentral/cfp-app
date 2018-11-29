FactoryBot.define do
  sequence :name do |n|
    "User Name #{n}"
  end

  sequence :email do |n|
    "email#{n}@factory.com"
  end

  factory :user do
    name
    email
    password { "12345678" }
    password_confirmation { "12345678" }
    bio { "A great Bio" }
    after(:create) { |user| user.confirm }

    trait :reviewer do
      name { "John Doe Reviewer" }
      after(:create) do |user|
        FactoryBot.create(:teammate, :reviewer, user: user)
      end
    end

    trait :organizer do
      name { "John Doe Organizer" }
      after(:create) do |user|
        FactoryBot.create(:teammate, :organizer, user: user)
      end
    end

    trait :program_team do
      name { "John Doe Program Team" }
      after(:create) do |user|
        FactoryBot.create(:teammate, :program_team, user: user)
      end
    end

    factory :admin do
      admin { true }
    end

    factory :organizer, traits: [ :organizer ] do
      transient do
        event { build(:event) }
      end

      after(:create) do |user, evaluator|
        teammate = user.organizer_teammates.first
        teammate.event = evaluator.event
        teammate.event.save
      end
    end

    factory :program_team, traits: [ :program_team ] do
      transient do
        event { build(:event) }
      end

      after(:create) do |user, evaluator|
        teammate = user.reviewer_teammates.first
        teammate.event = evaluator.event
        teammate.event.save
      end
    end

    factory :reviewer, traits: [ :reviewer ] do
      transient do
        event { build(:event) }
      end

      after(:create) do |user, evaluator|
        teammate = user.reviewer_teammates.first
        teammate.event = evaluator.event
        teammate.save
      end
    end
  end
end
