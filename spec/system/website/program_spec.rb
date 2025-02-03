require 'rails_helper'

feature "website program page" do
  let(:event) { create(:event) }
  let(:organizer) { create(:organizer, event: event) }
  let!(:website) { create(:website, event: event) }

  scenario "A program session is on the program session page", js: true do
    regular_session = create(:regular_session, event: event)

    visit program_path(event)
    expect(page).to have_content(regular_session.title)
  end

  scenario "the website program page displays sessions under the correct session format", js: true do
    regular_session = create(:regular_session, event: event)
    workshop = create(:workshop_session, event: event)
    visit program_path(event)

    expect(page).to have_content(regular_session.title)
    expect(page).to_not have_content(workshop.title)
    click_on('Workshop')
    expect(page).to have_content(workshop.title)
    expect(page).to_not have_content(regular_session.title)
  end

  scenario "the event website program page reflects updates to program sessions", js: true do
    login_as(organizer)
    regular_session = create(:regular_session, event: event)

    visit program_path(event)
    expect(page).to have_content(regular_session.title)

    visit edit_event_staff_program_session_path(event, regular_session)
    fill_in('Title', with: 'Updated Title')
    click_on('Save')
    expect(page).to have_content('Updated Title was successfully updated')

    visit program_path(event)
    expect(page).to have_content('Updated Title')
  end

  scenario "the event website page stops displaying deleted program sessions", js: true do
    login_as(organizer)
    regular_session = create(:regular_session, event: event)

    visit program_path(event)
    expect(page).to have_content(regular_session.title)

    visit edit_event_staff_program_session_path(event, regular_session)
    accept_confirm { click_on('Delete Program Session') }
    expect(page).to have_content('Program session was successfully deleted')

    visit program_path(event)
    expect(page).to_not have_content(regular_session.title)
  end
end
