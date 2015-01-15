FactoryGirl.define do
  sequence :email do |n|
    "email#{n}@factory.com"
  end

  factory :person do
    name "John Doe"
    email
    demographics { { gender: "female" } }
    bio "A great Bio"

    trait :reviewer do
      after(:create) do |person|
        FactoryGirl.create(:participant, :reviewer, person: person)
      end
    end

    trait :organizer do
      after(:create) do |person|
        FactoryGirl.create(:participant, :organizer, person: person)
      end
    end

    factory :admin do
      admin true
    end

    factory :organizer, traits: [ :organizer ] do
      transient do
        event { build(:event) }
      end

      after(:create) do |person, evaluator|
        participant = person.organizer_participants.first
        participant.event = evaluator.event
        participant.event.save
      end
    end

    factory :reviewer, traits: [ :reviewer ] do
      transient do
        event { build(:event) }
      end

      after(:create) do |person, evaluator|
        participant = person.reviewer_participants.first
        participant.event = evaluator.event
        participant.save
      end
    end
  end
end
