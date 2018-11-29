require 'rails_helper'

feature "Organizers can manage program sessions" do

  let!(:event) { create(:event) }
  let!(:session_format) { create(:session_format, event: event) }
  let!(:program_session) { create(:program_session, event: event, session_format: session_format) }

  let!(:organizer_user) { create(:user) }
  let!(:organizer) { create(:teammate, :organizer, user: organizer_user, event: event) }

  before :each do
    login_as(organizer_user)
  end

  context "organizer can promote a waitlisted program session" do
    let!(:waitlisted_session) { create(:program_session, event: event, session_format: session_format, state: ProgramSession::CONFIRMED_WAITLISTED) }

    scenario "from program session index", js: true do
      visit event_staff_program_sessions_path(event)
      page.accept_confirm do
        page.find('#waitlist').click
        find('tr', text: waitlisted_session.title).click_link("Promote")
      end

      expect(page).to_not have_css(".alert-danger")
      expect(waitlisted_session.reload.state).to eq(ProgramSession::LIVE)
    end

    scenario "from program session show page", js: true do
      visit event_staff_program_session_path(event, waitlisted_session)
      page.accept_confirm do
        click_link("Promote")
      end
      
      expect(page).to_not have_css(".alert-danger")
      expect(waitlisted_session.reload.state).to eq(ProgramSession::LIVE)
    end
  end

  context "organizer can promote a draft program session" do
    let!(:draft_session) { create(:program_session, event: event, session_format: session_format, state: ProgramSession::DRAFT) }

    scenario "from program session index", js: true do
      visit event_staff_program_sessions_path(event)
      page.accept_confirm do
        find('tr', text: draft_session.title).click_link("Promote")
      end

      expect(page).to_not have_css(".alert-danger")
      expect(draft_session.reload.state).to eq(ProgramSession::LIVE)
    end

    scenario "from program session show page", js: true do
      visit event_staff_program_session_path(event, draft_session)
      page.accept_confirm do
        click_link("Promote")
      end

      expect(page).to_not have_css(".alert-danger")
      expect(draft_session.reload.state).to eq(ProgramSession::LIVE)
    end
  end

  scenario "organizer can view program session" do
    visit event_staff_program_session_path(event, program_session)

    expect(page).to have_content(program_session.title)
    within(".page-header") do
      expect(page).to have_link("Edit")
    end
  end

  scenario "organizer can edit program session" do
    visit edit_event_staff_program_session_path(event, program_session)

    fill_in "Title", with: "New Session Title"
    fill_in "Video url", with: "http://www.youtube.com"
    click_on "Save"

    expect(current_path).to eq(event_staff_program_session_path(event, program_session))
    expect(page).to have_content("New Session Title")
    expect(page).to have_link("http://www.youtube.com")
  end

  scenario "organizer can add speaker to program session" do
    visit event_staff_program_session_path(event, program_session)

    click_link("Add Speaker")
    expect(current_path).to eq(new_event_staff_program_session_speaker_path(event, program_session))
    fill_in "speaker[speaker_name]", with: "Mary McSpeaker"
    fill_in "speaker[speaker_email]", with: "marymcspeaker@seed.event"

    click_on "Save"

    visit event_staff_program_session_path(event, program_session)
    within(".session-speakers") do
      expect(page).to have_content("Mary McSpeaker")
    end
  end

  scenario "organizer can create program session with a speaker" do
    visit event_staff_program_sessions_path(event)

    click_link("New Session")

    select session_format.name, from: "Format"
    fill_in "Title", with: "The Best Session"
    fill_in "Name", with: "Sally Speaker"
    fill_in "Email", with: "sallyspeaker@seed.event"
    click_on "Save"

    expect(page).to have_content("The Best Session")
  end

  scenario "organizer deleting program session deletes speaker if no proposals", js: true do
    speaker = create(:speaker, event: program_session.event, program_session: program_session)

    visit edit_event_staff_program_session_path(event, program_session)
    page.accept_confirm { click_on "Delete Program Session" }

    expect(current_path).to eq(event_staff_program_sessions_path(event))
    expect(page).not_to have_content(program_session.title)
    expect(event.speakers).not_to include(speaker)
  end

  scenario "organizer can delete program session without deleting speakers associated with a proposal", js: true do
    program_session_two = create(:program_session_with_proposal)
    speaker = create(:speaker, event: program_session_two.event, proposal: program_session_two.proposal, program_session: program_session_two)

    visit edit_event_staff_program_session_path(event, program_session_two)
    page.accept_confirm { click_on "Delete Program Session" }

    expect(current_path).to eq(event_staff_program_sessions_path(event))
    expect(page).not_to have_content(program_session_two.title)
    expect(event.speakers).to include(speaker)
    expect(event.proposals).to include(speaker.proposal)
  end

  scenario "organizer can confirm program session for speaker" do
    program_session_with_proposal = create(:program_session_with_proposal, :with_speaker, event: event, session_format: session_format)
    visit event_staff_program_session_path(event, program_session_with_proposal)

    click_link("Confirm for Speaker")

    expect(page).to have_content("Confirmed at:")
    expect(page).not_to have_link("Confirm for Speaker")
  end
end
