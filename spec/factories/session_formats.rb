FactoryBot.define do
  factory :session_format do
    event { Event.first || FactoryBot.create(:event) }
    sequence(:name) { |i| "Session Format#{i}" }
    description { Faker::Company.catch_phrase }
    duration { 30 }
    # add_attribute :public, true
    public { true }
  end
end
