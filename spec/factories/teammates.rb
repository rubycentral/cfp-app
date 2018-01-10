FactoryGirl.define do
  factory :teammate do
    event { Event.first || FactoryGirl.create(:event) }

    sequence :email do |n|
      "teammate_email#{n}@factory.com"
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
