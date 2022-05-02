FactoryBot.define do
  factory :sponsor do
    event { Event.first || create(:event) }
    name { Faker::Company.name }
    published { true }
    tier { 'platinum' }

    description { Faker::Hipster.paragraph }
    primary_logo_path = Rails.root.join('spec/fixtures/files/ruby1.png')
    primary_logo { Rack::Test::UploadedFile.new primary_logo_path, "image/png" }

    trait :with_footer_logo do
      footer_logo_path = Rails.root.join('spec/fixtures/files/ruby2.jpeg')
      footer_logo { Rack::Test::UploadedFile.new footer_logo_path, "image/jpeg" }
    end

    trait :with_offer do
      offer_headline { "A really great offer" }
      offer_url { "http://fakeoffer.com/" }
      offer_text { Faker::Hipster.paragraph }
    end
  end
end
