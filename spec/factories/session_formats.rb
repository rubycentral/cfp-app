FactoryGirl.define do
  factory :session_format do
    event { Event.first || FactoryGirl.create(:event) }
    name Faker::Book.genre
    description Faker::Company.catch_phrase
    duration 30
    add_attribute :public, true
  end
end
