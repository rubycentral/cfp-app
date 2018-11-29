# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :room do
    name { "MyString" }
    room_number { "MyString" }
    level { "MyString" }
    address { "MyString" }
    event
  end
end
