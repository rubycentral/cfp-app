FactoryBot.define do
  factory :proposal do
    event
    sequence(:title) { |i| "A fine proposal#{i}" }
    abstract { "This and that" }
    details { "Various other things" }
    pitch { "Baseball." }
    session_format { SessionFormat.first || FactoryBot.create(:session_format) }

    factory :proposal_with_track do
      event
      sequence(:title) { |i| "A fine proposal#{i}" }
      abstract { Faker::Hacker.say_something_smart }
      details { Faker::Hipster.sentence }
      pitch { Faker::Superhero.name }
      track
      session_format { SessionFormat.first || FactoryBot.create(:session_format, event: event) }
    end

    trait :with_reviewer_public_comment do
      after(:create) do |proposal|
        reviewer = FactoryBot.create(:reviewer, event: proposal.event)
        FactoryBot.create(:comment, proposal: proposal, type: "PublicComment", user: reviewer, body: "Reviewer comment" )
      end
    end

    trait :with_organizer_public_comment do
      after(:create) do |proposal|
        organizer = create(:organizer, event: proposal.event)
        create(:comment, proposal: proposal, type: "PublicComment", user: organizer, body: "Organizer comment" )
      end
    end

    trait :with_speaker do
      after(:create) do |proposal|
        program_session = create(:program_session, proposal: proposal, track: proposal.track)
        proposal.speakers << FactoryBot.create(:speaker, proposal: proposal, event: proposal.event, program_session: program_session)
      end
    end

    trait :with_two_speakers do
      after(:create) do |proposal|
        program_session = create(:program_session, proposal: proposal, track: proposal.track)
        proposal.speakers << FactoryBot.create(:speaker, proposal: proposal, event: proposal.event, bio: nil, program_session: program_session)
        proposal.speakers << FactoryBot.create(:speaker, proposal: proposal, event: proposal.event, bio: nil, program_session: program_session)
      end
    end
  end
end
