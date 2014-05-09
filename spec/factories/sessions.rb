# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :session do
    conference_day 1
    start_time "2014-01-31 10:41:58"
    end_time "2014-01-31 10:41:58"
    title "MyText"
    description "MyText"
    presenter "MyText"
    event

    factory :session_with_proposal do
      conference_day 1
      start_time "2014-01-31 10:41:58"
      end_time "2014-01-31 10:41:58"
      event
      proposal
    end
  end
end
