FactoryBot.define do
  factory :session_format do
    event { Event.first || FactoryBot.create(:event) }
    sequence(:name) { |i| "Session Format#{i}" }
    description { Faker::Company.catch_phrase }
    duration { 30 }
    # add_attribute :public, true
    public { true }

    factory :session_format_workshop do
      name { 'Workshop' }
      after(:create) do |session_format|
        session_format.session_format_config || create(:session_format_config, session_format: session_format)
      end
    end

    factory :session_format_regular_session do
      name { 'Regular Session' }
      after(:create) do |session_format|
        session_format.session_format_config || create(:session_format_config, session_format: session_format)
      end
    end
  end
end
