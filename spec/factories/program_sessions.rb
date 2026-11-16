FactoryBot.define do
  factory :program_session do
    sequence(:title) { |i| "Default Session #{i}" }
    abstract { "Just some abstract" }
    state { :live }
    session_format
    event

    factory :program_session_with_proposal do
      proposal { create(:proposal_with_track, state: :accepted, event: event) }
      track { proposal.track }

      trait :with_speaker do
        after(:create) do |program_session|
          program_session.speakers << create(:speaker, event: program_session.event)
        end
      end
    end
  end
end
