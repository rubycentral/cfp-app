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
    end

    factory :session_format_regular_session do
      name { 'Regular Session' }
    end
  end
end
