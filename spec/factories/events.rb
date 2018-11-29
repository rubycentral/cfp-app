FactoryBot.define do
  factory :event do
    sequence(:name) { |i| "Fine Event#{i}" }
    url { "http://fineevent.com/" }
    guidelines { "We want all the good talks!" }
    contact_email { "admin@example.com" }
    start_date { DateTime.now + 25.days }
    end_date { DateTime.now + 30.days }
    closes_at { 3.weeks.from_now.to_datetime }
  end
end
