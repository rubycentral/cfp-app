FactoryGirl.define do
  factory :participant do
    event { Event.first || FactoryGirl.create(:event) }
    user { User.first || FactoryGirl.create(:user) }

    trait :reviewer do
      role 'reviewer'
    end

    trait :organizer do
      role 'organizer'
    end

  end
end
