FactoryBot.define do
  factory :event do
    sequence(:name) { |i| "Fine Event#{i}" }
    url { "http://fineevent.com/" }
    guidelines { "We want all the good talks!" }
    contact_email { "admin@example.com" }
    start_date { 25.days.from_now }
    end_date { 30.days.from_now }
    closes_at { 3.weeks.from_now }
  end
end
