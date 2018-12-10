FactoryBot.define do
  factory :tagging do
    tag { "intro" }
  end

  trait :review_tagging do
    internal { true }
  end
end
