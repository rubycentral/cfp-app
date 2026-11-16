# Factories only the website specs use (program/schedule pages group sessions
# by session format config).
FactoryBot.define do
  factory :session_format_workshop, parent: :session_format do
    name { 'Workshop' }
    after(:create) do |session_format|
      session_format.session_format_config || create(:session_format_config, session_format: session_format)
    end
  end

  factory :session_format_regular_session, parent: :session_format do
    name { 'Regular Session' }
    after(:create) do |session_format|
      session_format.session_format_config || create(:session_format_config, session_format: session_format)
    end
  end

  factory :workshop_session, parent: :program_session do
    session_format { SessionFormat.find_by(name: 'Workshop') || create(:session_format_workshop) }
  end

  factory :regular_session, parent: :program_session do
    session_format { SessionFormat.find_by(name: 'Regular Session') || create(:session_format_regular_session) }
  end

  factory :with_workshop_session, parent: :time_slot do
    program_session { FactoryBot.create(:workshop_session) }
  end
end
