FactoryGirl.define do
  factory :speaker do
    user
    event { Event.first || FactoryGirl.create(:event) }
    bio "Speaker bio"
  end
end
