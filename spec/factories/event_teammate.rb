FactoryGirl.define do
  factory :event_teammate do
    event { Event.first || FactoryGirl.create(:event) }
    user { User.first || FactoryGirl.create(:user) }

    trait :reviewer do
      role 'reviewer'
    end

    trait :program_team do
      role 'program team'
    end

    trait :organizer do
      role 'organizer'
    end

  end
end
