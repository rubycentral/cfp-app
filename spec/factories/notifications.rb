# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :notification do
    user nil
    message "MyString"
    read_at DateTime.now
    target_path 'MyString'
  end
end
