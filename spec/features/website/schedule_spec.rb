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

  scenario "the schedule page display sponsor information for time slots with sponsors", js: true do
    sponsor = create(:sponsor)
    time_slot = create(:time_slot, event: event)

    visit schedule_path(event)

    expect(page).to_not have_content('Sponsored')
    click_on(time_slot.title)
    expect(page).to_not have_content(sponsor.description)

    time_slot.update(sponsor: sponsor)

    visit schedule_path(event)
    expect(page).to have_content('Sponsored')
    click_on(time_slot.title)
    expect(page).to have_content(sponsor.description)
  end

  scenario "the event website schedule page displays time slots that have program sessions", js: true do
    skip "FactoryBot 😤"
    time_slot = create(:with_workshop_session, event: event)

    visit schedule_path(event)
    expect(page).to have_content(time_slot.title)
  end

  scenario "the event website schedule page displays updates to time slots that have program sessions", js: true do
    skip "FactoryBot 😤"
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

  scenario 'Public views schedule page on custom domain' do
    website.update(domains: 'www.example.com')
    visit schedule_path
    expect(current_path).to eq('/schedule')
  end

  context "schedule page loads on the correct conference day" do
    it "displays the first event day before the conference start" do
      travel_to(event.start_date - 1.day) do
        visit schedule_path(event)
        expect(page).to have_selector('#schedule-day-1', visible: true)
        expect(page).to have_selector('#schedule-day-2', visible: false)
        selected_day = find('a.selected')
        expect(selected_day).to have_content(event.conference_date(1).strftime("%B %-e"))
      end
    end

    it "displays the first event day on the first event day" do
      travel_to(event.start_date) do
        visit schedule_path(event)
        expect(page).to have_selector('#schedule-day-1', visible: true)
        expect(page).to have_selector('#schedule-day-2', visible: false)
        selected_day = find('a.selected')
        expect(selected_day).to have_content(event.conference_date(1).strftime("%B %-e"))
      end
    end

    it "displays the second event day on the second event day" do
      travel_to(event.start_date + 1.day + 1.seconds) do
        visit schedule_path(event)
        expect(page).to have_selector('#schedule-day-1', visible: false)
        expect(page).to have_selector('#schedule-day-2', visible: true)
        selected_day = find('a.selected')
        expect(selected_day).to have_content(event.conference_date(2).strftime("%B %-e"))
      end
    end

    it "displays the start of the event after the event" do
      travel_to(event.start_date + event.days.days + 1.seconds ) do
        visit schedule_path(event)
        expect(page).to have_selector('#schedule-day-1', visible: false)
        expect(page).to have_selector('#schedule-day-2', visible: true)
        selected_day = find('a.selected')
        expect(selected_day).to have_content(event.conference_date(1).strftime("%B %-e"))
      end
    end
  end
end
