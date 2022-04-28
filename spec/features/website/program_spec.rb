require 'rails_helper'

feature "website program page" do
  let(:event) { create(:event) }
  let(:organizer) { create(:organizer, event: event) }
  let!(:website) { create(:website, event: event) }


  let(:regular_session_format) { create(:session_format_regular_session) }
  let(:workshop_session_format) { create(:session_format_workshop) }



  scenario "the event website program page displays live regular sessions" do
    regular_session = create(:program_session, event: event, session_format: regular_session_format)
    visit program_path(event)

    within('#sessions') { expect(page).to have_content(regular_session.title) }
  end

  scenario "the event website program page displays live workshops" do
    workshop = create(:program_session, event: event, session_format: workshop_session_format)
    visit program_path(event)

    within('#workshops') { expect(page).to have_content(workshop.title) }
  end

  scenario "the event website program page reflects updates to program sessions" do
    login_as(organizer)
    regular_session = create(:program_session, event: event, session_format: regular_session_format)
    visit program_path(event)

    within('#sessions') { expect(page).to have_content(regular_session.title) }

    visit edit_event_staff_program_session_path(event, regular_session)
    fill_in('Title', with: 'Updated Title')
    click_on('Save')

    expect(page).to have_content('Updated Title was successfully updated')
    visit program_path(event)
    within('#sessions') { expect(page).to have_content('Updated Title') }
  end

  scenario "the event website page stops displaying deleted program sessions", js: true do
    login_as(organizer)
    regular_session = create(:program_session, event: event, session_format: regular_session_format)

    visit program_path(event)
    within('#sessions') { expect(page).to have_content(regular_session.title) }

    visit edit_event_staff_program_session_path(event, regular_session)
    accept_confirm { click_on('Delete Program Session') }
    expect(page).to have_content('Program session was successfully deleted')

    visit program_path(event)
    within('#sessions') { expect(page).to_not have_content(regular_session.title) }
  end
end
