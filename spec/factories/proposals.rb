FactoryGirl.define do
  factory :proposal do
    event { Event.first || FactoryGirl.create(:event) }
    sequence(:title) { |i| "A fine proposal#{i}" }
    abstract "This and that"
    details "Various other things"
    pitch "Baseball."


    trait :with_reviewer_public_comment do
      after(:create) do |proposal|
        reviewer = FactoryGirl.create(:person, :reviewer)
        FactoryGirl.create(:comment, proposal: proposal, type: "PublicComment", person: reviewer, body: "Reviewer comment" )
      end
    end

    trait :with_organizer_public_comment do
      after(:create) do |proposal|
        organizer = FactoryGirl.create(:organizer, event: proposal.event )
        FactoryGirl.create(:comment, proposal: proposal, type: "PublicComment", person: organizer, body: "Organizer comment" )
      end
    end

    trait :with_speaker do
      after(:create) do |proposal|
        proposal.speakers << FactoryGirl.create(:speaker)
      end
    end
  end
end
