FactoryGirl.define do
  factory :teammate do
    event { Event.first || FactoryGirl.create(:event) }

    sequence :email do |n|
      "email#{n}@factory.com"
    end

    sequence :mention_name do |n|
      "teammate#{n}"
    end

    trait :has_been_invited do
      token "token"
      role "reviewer"
      state Teammate::PENDING
    end

    trait :reviewer do
      role "reviewer"
    end

    trait :program_team do
      role "program team"
    end

    trait :organizer do
      role "organizer"
    end

  end
end
