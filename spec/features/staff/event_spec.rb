require 'rails_helper'

feature "Event Dashboard" do
  let(:organizer_user) { create(:user) }
  let!(:organizer_teammate) { create(:teammate,
                                       user: organizer_user,
                                       role: "organizer")
  }

  let(:reviewer_user) { create(:user) }
  let!(:reviewer_teammate) { create(:teammate,
                                      user: reviewer_user,
                                      role: "reviewer")
  }

  let(:program_team_user) { create(:user) }
  let!(:program_team_teammate) { create(:teammate,
                                      user: program_team_user,
                                      role: "program_team")
  }

  context "As an organizer" do
    before :each do
      logout
      login_as(organizer_user)
    end

    it "cannot create new events" do
      visit new_admin_event_path
      expect(page.current_path).to eq(events_path)
      expect(page).to have_text("You must be signed in as an administrator")
    end

    it "can edit events" do
      visit event_staff_info_path(organizer_teammate.event)
      expect(page).to have_content organizer_teammate.event.name
      expect(page).to have_link "Edit Info"
      expect(page).not_to have_link "Change Status"

      click_on "Edit Info"

      fill_in "Name", with: "Blef"
      click_button "Save"
      expect(page).to have_text("Blef")
      expect(current_path).to eq(event_staff_info_path(organizer_teammate.event))
    end

    it "can change event status if checklist complete" do
      event = organizer_teammate.event
      visit event_staff_info_path(event)
      expect(page).not_to have_link "Change Status"
      create(:program_session, event: event)
      visit event_staff_info_path(event)

      within('.page-header') do
        expect(page).to have_content("Event Status: Draft")
      end

      click_link("Change Status")
      select('open', :from => 'event[state]')
      click_button("Update Status")

      within('.page-header') do
        expect(page).to have_content("Event Status: Open")
      end
    end

    it "cannot delete events" do
      visit event_staff_path(organizer_teammate.event)
      expect(page).not_to have_link("Delete Event")
    end
  end

  context "As a reviewer" do
    before :each do
      logout
      login_as(reviewer_user)
    end

    it "cannot vist event edit pages" do
      visit event_staff_edit_path(reviewer_teammate.event)
      expect(page).to have_content "You are not authorized to perform this action."
    end

    it "cannot see event edit buttons" do
      visit event_staff_info_path(reviewer_teammate.event)
      expect(page).not_to have_link "Edit Info"
      expect(page).not_to have_link "Change Status"
    end
  end

  context "As a program team" do
    before :each do
      logout
      login_as(program_team_user)
    end

    it "cannot vist event edit pages" do
      visit event_staff_edit_path(program_team_teammate.event)
      expect(page).to have_content "You are not authorized to perform this action."
    end

    it "cannot see event edit buttons" do
      visit event_staff_info_path(program_team_teammate.event)
      expect(page).not_to have_link "Edit Info"
      expect(page).not_to have_link "Change Status"
    end
  end
end
