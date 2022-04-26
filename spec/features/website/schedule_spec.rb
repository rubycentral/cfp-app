require 'rails_helper'

feature "dynamic website schedule page" do
  let(:event) { create(:event) }
  let!(:website) { create(:website, event: event) }

  scenario "the event website schedule page updates when a time slot is updated" do
    time_slot = create(:time_slot, event: event)
    visit schedule_path(event)

    within('.schedule-block-container') { expect(page).to have_content('10:41') }
    time_slot.update(start_time: (time_slot.start_time - 1.hour))

    visit schedule_path(event)
    within('.schedule-block-container') { expect(page).to have_content('9:41') }
  end

  scenario "when a program session is edited that change is reflected on the schedule" do
    time_slot = create(:time_slot_with_program_session, event: event)
    program_session = time_slot.program_session

    visit schedule_path(event)
    expect(page).to have_content(time_slot.title)

    program_session.update(title: "New Title")
    visit schedule_path(event)
    expect(page).to have_content("New Title")
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
    click_on(event.conference_date(2).strftime("%B %e"))

    expect(page)
      .to have_link(event.conference_date(2).strftime("%B %e"), class: "selected")
    expect(page).to_not have_content(time_slot.title)
    time_slot.update(conference_day: 2)

    visit schedule_path(event)
    expect(page).to_not have_content(time_slot.title)
    click_on(event.conference_date(2).strftime("%B %e"))

    expect(page).to have_content(time_slot.title)
  end
end
