FactoryGirl.define do
  factory :participant do
    event { Event.first || FactoryGirl.create(:event) }
    person { Person.first || FactoryGirl.create(:person) }

    trait :reviewer do
      role 'reviewer'
    end

    trait :organizer do
      role 'organizer'
    end

  end
end
