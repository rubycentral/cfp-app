# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :notification do
    user { nil }
    message { "MyString" }
    read_at { DateTime.now }
    target_path { '/events' }

    trait :unread do
      read_at { nil }
    end

    trait :with_long_message do
      message { "Lorem ipsum dolor sit amet, consectetur adipisicing elit. Suscipit ut nobis nemo dolore architecto aliquam." }
    end

  end
end
