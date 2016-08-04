require 'rails_helper'

feature "Staff Organizers can manage teammates" do
  let(:invitation) { create(:teammate, :has_been_invited) }

  let!(:organizer_user) { create(:user) }
  let!(:organizer_teammate) { create(:teammate, :organizer, user: organizer_user, event: invitation.event, state: Teammate::ACCEPTED) }

  let!(:reviewer_user) { create(:user) }
  let!(:reviewer_teammate) { create(:teammate, :reviewer, user: reviewer_user, event: invitation.event, state: Teammate::ACCEPTED) }

  let!(:program_team_user) { create(:user) }
  let!(:program_team_teammate) { create(:teammate, :program_team, user: program_team_user, event: invitation.event, state: Teammate::ACCEPTED) }

  before { login_as(organizer_user) }

  context "adding a new teammate" do
    it "invites a new teammate", js: true do
      visit event_staff_teammates_path(invitation.event)

      click_link "Invite new teammate"
      fill_in "Email", with: "harrypotter@hogwarts.edu"
      select("reviewer", from: "Role")
      click_button "Invite"

      expect(page).to have_text("harrypotter@hogwarts.edu")
      expect(page).to have_text("pending")
    end
  end

  context "editing existing teammates" do
    it "changes a teammates role", js: true do
      visit event_staff_teammates_path(invitation.event)
      row = find("tr#teammate-#{program_team_teammate.id}")

      within "#teammate-role-#{program_team_teammate.id}" do
        click_link "Change Role"
      end
      select "reviewer", from: "Role"
      click_button "Save"

      expect(row).to have_content(program_team_teammate.email)
      expect(row).to have_content("reviewer")
    end

    it "removes a teammate", js: true do
      visit event_staff_teammates_path(invitation.event)
      find("tr#teammate-#{reviewer_teammate.id}")

      within "#teammate-role-#{reviewer_teammate.id}" do
        page.accept_confirm { click_on "Remove" }
      end

      expect(page).to have_content("#{reviewer_teammate.email} was removed.")
      page.reset!
      expect(page).not_to have_content(reviewer_teammate.email)
      expect(page).not_to have_content("reviewer")
    end
  end

  context "A reviewer cannot edit other teammates" do
    before :each do
      logout
      login_as(reviewer_user)
    end

    it "cannot view buttons to edit event or change status" do
      visit event_staff_teammates_path(invitation.event)

      expect(page).to_not have_link("Change Role")
      expect(page).to_not have_link("Remove")
      expect(page).to_not have_link("Invite new teammate")
    end
  end

  context "A program team cannot edit other teammates" do
    before :each do
      logout
      login_as(program_team_user)
    end

    it "cannot view buttons to edit event or change status" do
      visit event_staff_teammates_path(invitation.event)

      expect(page).to_not have_link("Change Role")
      expect(page).to_not have_link("Remove")
      expect(page).to_not have_link("Invite new teammate")
    end
  end

end
