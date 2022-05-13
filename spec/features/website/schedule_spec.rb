require 'rails_helper'

feature "dynamic website schedule page" do
  let(:event) { create(:event) }
  let!(:website) { create(:website, event: event) }

  scenario "the event website schedule page displays time slots that don't have program sessions" do
    time_slot = create(:time_slot, event: event)
    visit schedule_path(event)

    expect(page).to have_content(time_slot.title)
    within('.schedule-block-container') { expect(page).to have_content('10:41') }
  end

  scenario "the event website schedule page displays updates to time slots that don't have program sessions" do
    time_slot = create(:time_slot, event: event)

    time_slot.update(start_time: (time_slot.start_time - 1.hour), title: 'Updated Title')

    visit schedule_path(event)
    within('.schedule-block-container') { expect(page).to have_content('9:41') }
    expect(page).to have_content('Updated Title')
  end

  scenario "the event website schedule page displays time slots that have program sessions", js: true do
    time_slot = create(:with_workshop_session, event: event)

    visit schedule_path(event)
    expect(page).to have_content(time_slot.title)
  end

  scenario "the event website schedule page displays updates to time slots that have program sessions", js: true do
    time_slot = create(:with_workshop_session, event: event)

    time_slot.update(start_time: (time_slot.start_time - 1.hour))
    time_slot.program_session.update(title: "Updated Title")

    visit schedule_path(event)
    expect(page).to have_content("Updated Title")
    expect(page).to have_content('9:41')
  end

  scenario "the event website schedule stops displaying time slots when they are deleted" do
    time_slot = create(:time_slot, event: event)
    visit schedule_path(event)

    expect(page).to have_content(time_slot.title)
    time_slot.destroy

    visit schedule_path(event)
    expect(page).not_to have_content(time_slot.title)
  end

  scenario "schedule sub naivgation displays the correct program sessions", js: true do
    time_slot = create(:time_slot, event: event)
    visit schedule_path(event)

    expect(page).to have_content(time_slot.title)
    click_on(event.conference_date(2).strftime("%B %-e"))

    expect(page)
      .to have_link(event.conference_date(2).strftime("%B %-e"), class: "selected")
    expect(page).to_not have_content(time_slot.title)
    time_slot.update(conference_day: 2)

    visit schedule_path(event)
    expect(page).to_not have_content(time_slot.title)
    click_on(event.conference_date(2).strftime("%B %-e"))

    expect(page).to have_content(time_slot.title)
  end
end
