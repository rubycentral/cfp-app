require 'rails_helper'

feature 'Staff Organizers can manage time slots', type: :system do
  let(:event) { create(:event, start_date: Date.today, end_date: Date.today + 2.days) }
  let!(:room) { create(:room, name: 'Main Hall', event: event) }
  let!(:organizer_user) { create(:organizer, event: event) }

  before { login_as(organizer_user) }

  scenario 'creates a time slot via the "Save and Add" button', js: true do
    visit event_staff_schedule_time_slots_path(event)

    click_link 'Add Time Slot'

    within('#time-slot-new-dialog') do
      select '1', from: 'Day'
      select 'Main Hall', from: 'Room'
      click_button 'Save and Add'
    end

    expect(page).to have_content('Time slot added.')
    expect(event.time_slots.count).to eq(1)
    expect(page).to have_css('#organizer-time-slots tbody tr')
  end
end
