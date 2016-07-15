# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :time_slot do
    conference_day 1
    start_time "2014-01-31 10:41:58"
    end_time "2014-01-31 10:41:58"
    title "MyText"
    description "MyText"
    presenter "MyText"
    event

    factory :time_slot_with_program_session do
      conference_day 1
      start_time "2014-01-31 10:41:58"
      end_time "2014-01-31 10:41:58"
      event
      program_session { FactoryGirl.create(:program_session_with_proposal)}
    end

    factory :time_slot_with_empty_program_session do
      conference_day 1
      start_time "2014-01-31 10:41:58"
      end_time "2014-01-31 10:41:58"
      event
      program_session
    end
  end
end
