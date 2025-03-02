FactoryBot.define do
  factory :page do
    website { Website.first || create(:website) }
    name { 'Home' }
    sequence(:slug) { |i| "home#{i if i > 1}" }
    unpublished_body { "<p>#{Faker::Lorem.paragraph}</p>" }
    published_body { "<p>#{Faker::Lorem.paragraph}</p>" }
    body_published_at { 1.day.ago }
  end
end
