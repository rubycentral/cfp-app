FactoryBot.define do
  factory :page do
    website { Website.first || create(:website) }
    name { 'Home' }
    slug { 'home' }
    unpublished_body { "<p>#{Faker::Lorem.paragraph}</p>" }
    published_body { "<p>#{Faker::Lorem.paragraph}</p>" }
  end
end
