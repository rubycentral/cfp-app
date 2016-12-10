FactoryGirl.define do
  factory :service do
    provider "Developer"
    uname "foo"
    uid "foo@example.com"
    uemail "foo@example.com"
    user
  end
end
