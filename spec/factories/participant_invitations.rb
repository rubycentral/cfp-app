# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :participant_invitation do
    email "user@example.com"
    slug "MyString"
    role "MyString"
    event
  end
end
