FactoryBot.define do
  factory :website do
    event
    trait :with_details do
      city { Faker::Address.city }
      location { Faker::Address.full_address }
      prospectus_link { Faker::Internet.url }
      twitter_handle { Faker::Internet.username }
      directions { Faker::Internet.url }
      after :create do |page|
        file_path = Rails.root.join('spec', 'fixtures', 'files', 'ruby1.png')
        file = Rack::Test::UploadedFile.new(file_path, 'image/png')
        page.logo.attach(file)
        page.background.attach(file)
      end
    end
  end
end
