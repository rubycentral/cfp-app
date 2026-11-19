require 'rails_helper'

feature 'Staff Organizers can manage time slots', type: :system do
  let(:event) { create(:event, start_date: Date.today, end_date: Date.today + 2.days) }
  let!(:room) { create(:room, name: 'Main Hall', event: event) }
  let!(:organizer_user) { create(:organizer, event: event) }

  before { login_as(organizer_user) }

  context 'tracks' do
    let!(:session_format) { create(:session_format, event: event) }

    context 'when the event has no tracks' do
      let!(:program_session) { create(:program_session, event: event, session_format: session_format) }

      scenario 'no track column, field or card tag on the schedule pages', js: true do
        visit event_staff_schedule_time_slots_path(event)
        expect(page).to have_css('th', text: 'Room')
        expect(page).not_to have_css('th', text: 'Track')

        click_link 'Add Time Slot'
        within('#time-slot-new-dialog') do
          expect(page).to have_select('Room')
          expect(page).not_to have_select('Track')
        end

        visit event_staff_schedule_grid_path(event)
        expect(page).to have_css('.draggable-session-card', count: 1)
        expect(page).not_to have_css('.draggable-session-card .track', visible: :all)
      end
    end

    context 'when the event has several tracks' do
      let!(:tracks) { %w[Hardware Software Community].map { |name| create(:track, event: event, name: name) } }
      let!(:program_sessions) do
        tracks.map { |track| create(:program_session, event: event, session_format: session_format, track: track) }
      end

      scenario 'colours each track badge on the schedule grid from the fixed palette', js: true do
        visit event_staff_schedule_grid_path(event)
        expect(page).to have_css('.draggable-session-card .track', count: 3)

        colours = page.evaluate_script(
          "Array.from(document.querySelectorAll('.draggable-session-card .track')).map(el => el.style.backgroundColor)"
        )
        expect(colours).to match_array(['rgb(120, 28, 129)', 'rgb(131, 186, 109)', 'rgb(217, 33, 32)'])
      end
    end

    context 'when the event has a track' do
      let!(:track) { create(:track, event: event, name: 'Hardware') }
      let!(:program_session) { create(:program_session, event: event, session_format: session_format, track: track) }

      scenario 'track column, field and card tag on the schedule pages', js: true do
        visit event_staff_schedule_time_slots_path(event)
        expect(page).to have_css('th', text: 'Track')

        click_link 'Add Time Slot'
        within('#time-slot-new-dialog') do
          expect(page).to have_select('Track')
        end

        visit event_staff_schedule_grid_path(event)
        expect(page).to have_css('.draggable-session-card .track', text: 'Hardware')
      end
    end
  end

  scenario 'shows the slot length as the start and end times change', js: true do
    visit event_staff_schedule_time_slots_path(event)

    click_link 'Add Time Slot'

    within('#time-slot-new-dialog') do
      select '09:00', from: 'Start time'
      select '09:45', from: 'End time'
      expect(page).to have_css('.length', text: '45 minutes')

      select '11:05', from: 'End time'
      expect(page).to have_css('.length', text: '125 minutes')
    end
  end

  scenario 'labels the schedule grid ruler with 12-hour times', js: true do
    visit event_staff_schedule_grid_path(event)

    within('.schedule-ruler') do
      expect(page).to have_css('.ruler-tick', count: 11)
      expect(page).to have_css('.ruler-tick:first-child', text: '09:00am')
      expect(page).to have_css('.ruler-tick', text: '12:00pm')
      expect(page).to have_css('.ruler-tick:last-child', text: '07:00pm')
    end
  end

  context 'with an existing time slot' do
    # Round times, so the edit dialog's time selects can show the slot's current values
    let!(:time_slot) { create(:time_slot, event: event, room: room, conference_day: 1, start_time: '10:00', end_time: '11:00') }

    scenario 'removes it', js: true do
      visit event_staff_schedule_time_slots_path(event)

      within("#time_slot_#{time_slot.id}") do
        accept_confirm { click_on 'Remove' }
      end

      expect(page).not_to have_css("#time_slot_#{time_slot.id}")
      expect(TimeSlot.exists?(time_slot.id)).to be false
    end

    scenario 'moves it to another day', js: true do
      visit event_staff_schedule_time_slots_path(event)
      within("#time_slot_#{time_slot.id}") { click_on 'Edit' }

      within('#time-slot-edit-dialog') do
        select '3', from: 'Day'
        click_button 'Save'
      end

      within("#time_slot_#{time_slot.id}") { expect(page).to have_css('td', text: '3') }
      expect(time_slot.reload.conference_day).to eq(3)
    end

    scenario 'schedules a program session into it', js: true do
      program_session = create(:program_session_with_proposal, event: event)
      visit event_staff_schedule_time_slots_path(event)
      within("#time_slot_#{time_slot.id}") { click_on 'Edit' }

      within('#time-slot-edit-dialog') do
        select program_session.title, from: 'Program session'
        click_button 'Save'
      end

      within("#time_slot_#{time_slot.id}") { expect(page).to have_text(program_session.title) }
      expect(time_slot.reload.program_session).to eq(program_session)
    end
  end

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
