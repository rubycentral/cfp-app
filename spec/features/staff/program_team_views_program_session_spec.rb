require 'rails_helper'

feature "Program team views program sessions" do

  let(:event) { create(:event) }
  let(:program_session) { create(:program_session, event: event) }

  let(:program_team_user) { create(:user) }
  let!(:program_team_member) { create(:teammate, :program_team, user: program_team_user, event: event) }

  before :each do
    login_as(program_team_user)
  end

  scenario "program team can view program sessions" do
    visit event_staff_program_sessions_path(event)

    expect(page).to have_content("Sessions")
    expect(page).not_to have_link("New Session")
  end

  scenario "program team can view program session" do
    visit event_staff_program_session_path(event, program_session)

    expect(page).to have_content(program_session.title)
  end

  scenario "program team cannot edit program session" do
    visit event_staff_program_session_path(event, program_session)

    expect(page).to have_content(program_session.title)
    expect(page).not_to have_link("Edit")

    visit edit_event_staff_program_session_path(event, program_session)

    expect(current_path).to eq(events_path)
    expect(page).to have_content("You are not authorized to perform this action.")
  end

  scenario "program team cannot add speaker to program session" do
    visit event_staff_program_session_path(event, program_session)

    expect(page).to have_content(program_session.title)
    expect(page).not_to have_content("Add Speaker")
  end
end
