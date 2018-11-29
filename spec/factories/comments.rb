FactoryBot.define do
  factory :comment do
    body { "Hello" }
    type { "PublicComment" }

    trait :internal do
      type { "InternalComment" }
    end
  end
end
