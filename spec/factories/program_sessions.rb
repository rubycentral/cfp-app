FactoryGirl.define do
  factory :program_session do
    title 'Default Session'
    abstract 'Just some abstract'
    state ProgramSession::ACTIVE
    session_format
    event

    factory :program_session_with_proposal do
      proposal { FactoryGirl.build(:proposal, state: Proposal::ACCEPTED) }
    end
  end
end
