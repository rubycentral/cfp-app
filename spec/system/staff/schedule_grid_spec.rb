require 'rails_helper'

feature 'Staff organizers build the schedule on the grid', type: :system, js: true do
  let(:event) { create(:event, start_date: Date.today, end_date: Date.today + 2.days) }
  let!(:room) { create(:room, name: 'Main Hall', grid_position: 1, event: event) }
  let!(:session_format) { create(:session_format, name: 'Talk', duration: 30, event: event) }
  let!(:organizer_user) { create(:organizer, event: event) }

  before { login_as(organizer_user) }

  def open_bulk_dialog
    visit event_staff_schedule_grid_path(event)
    click_link 'Generate Grid'
    within('#grid-modal') { expect(page).to have_text('Bulk Generate Time Slots') }
  end

  scenario 'generates a day of time slots in bulk, previewing them first' do
    open_bulk_dialog

    within('#grid-modal') do
      check 'Main Hall'
      fill_in 'Start times', with: '10:00, 11:00'
      select 'Talk (30 min)', from: 'Session format'
      click_button 'Preview'
    end

    expect(page).to have_text('Previewing grid changes')
    expect(page).to have_css('#schedule_day_1 .time-slot.preview', count: 2)
    expect(event.time_slots.count).to eq(0)

    click_button 'Save'

    expect(page).to have_text('Time slots created successfully.')
    expect(page).to have_css('#schedule_day_1 .time-slot', count: 2)
    expect(page).not_to have_css('.time-slot.preview')
    times = event.time_slots.order(:start_time).map { |ts| [ts.start_time.to_fs(:time), ts.end_time.to_fs(:time)] }
    expect(times).to eq([['10:00', '10:30'], ['11:00', '11:30']])
  end

  scenario 'discards a previewed grid' do
    open_bulk_dialog

    within('#grid-modal') do
      check 'Main Hall'
      fill_in 'Start times', with: '10:00'
      fill_in 'Custom duration (minutes)', with: '45'
      click_button 'Preview'
    end
    expect(page).to have_css('.time-slot.preview', count: 1)

    click_link 'Cancel'

    expect(page).not_to have_css('.time-slot.preview')
    expect(page).not_to have_text('Previewing grid changes')
    expect(event.time_slots.count).to eq(0)
  end

  scenario 'refuses to preview without a room' do
    open_bulk_dialog

    within('#grid-modal') do
      fill_in 'Start times', with: '10:00'
      fill_in 'Custom duration (minutes)', with: '45'
      click_button 'Preview'
      expect(page).to have_css('#bulk-errors', text: "Rooms can't be blank")
    end
    expect(page).not_to have_css('.time-slot.preview')
  end

  context 'with an empty time slot on the grid' do
    let!(:time_slot) do
      create(:time_slot, event: event, room: room, conference_day: 1, start_time: '10:00', end_time: '11:00',
             title: nil, presenter: nil, description: nil)
    end
    let(:slot_selector) { "#time_slot_time_slot_#{time_slot.id}" }

    scenario 'turns it into a custom session from the edit dialog' do
      visit event_staff_schedule_grid_path(event)
      find(slot_selector).click

      within('#grid-modal') do
        expect(page).to have_text('Edit Time Slot')
        fill_in 'Title', with: 'Lunch'
        fill_in 'Presenter', with: 'Catering'
        click_button 'Save'
      end

      within(slot_selector) { expect(page).to have_text('Lunch') }
      expect(time_slot.reload).to have_attributes(title: 'Lunch', presenter: 'Catering')
    end

    scenario 'schedules a program session into it from the edit dialog' do
      program_session = create(:program_session, event: event, session_format: session_format, title: 'Keynote')
      create(:speaker, program_session: program_session, event: event, speaker_name: 'Ada Lovelace')
      visit event_staff_schedule_grid_path(event)
      expect(page).to have_css('#unscheduled-sessions-badge', text: '1/1')
      expect(page).to have_css('#schedule-day-1-badge', text: '0/1')

      find(slot_selector).click
      within('#grid-modal') do
        select 'Keynote', from: 'Program session'
        click_button 'Save'
      end

      # Cards show their speakers until "Show Titles" is toggled
      within(slot_selector) { expect(page).to have_css('.draggable-session-card', text: 'Ada Lovelace') }
      expect(page).to have_css('#unscheduled-sessions-badge', text: '0/1')
      expect(page).to have_css('#schedule-day-1-badge', text: '1/1')
      expect(time_slot.reload.program_session).to eq(program_session)
    end
  end

  scenario "shows an unscheduled session's details from the pool" do
    program_session = create(:program_session, event: event, session_format: session_format, title: 'Keynote', abstract: 'All about keys')
    create(:speaker, program_session: program_session, event: event, speaker_name: 'Ada Lovelace')
    visit event_staff_schedule_grid_path(event)

    find('.draggable-session-card', text: 'Ada Lovelace').click

    within('#grid-modal') do
      expect(page).to have_css('h3', text: 'Keynote')
      expect(page).to have_text('Format:')
      expect(page).to have_text('Talk')
      expect(page).to have_text('Presenter:')
      expect(page).to have_text('Ada Lovelace')
      expect(page).to have_text('All about keys')
    end
  end
end
