FactoryGirl.define do
  factory :rating do
    association :proposal
    association :person
    score 3
  end
end
