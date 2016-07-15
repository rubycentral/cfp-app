FactoryGirl.define do
  factory :session_format do
    event { Event.first || FactoryGirl.create(:event) }
    name "Default Format"
    duration 30
    add_attribute :public, true
  end
end
