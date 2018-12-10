FactoryBot.define do
  factory :rating do
    association :proposal
    association :user
    score { 3 }
  end
end
