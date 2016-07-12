FactoryGirl.define do
  factory :session_format do
    event { Event.first || FactoryGirl.create(:event) }
    name "Default Session"
    add_attribute :public, true
  end
end
