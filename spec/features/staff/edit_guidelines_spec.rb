require 'rails_helper'

feature "Event Guidelines" do
  let(:event) { create(:event, name: "My Event") }
  let(:admin_user) { create(:user, admin: true) }
  let!(:admin_teammate) { create(:teammate,
                                   event: event,
                                   user: admin_user,
                                   role: "organizer"
                                  )
  }

  let(:organizer_user) { create(:user) }
  let!(:event_staff_teammate) { create(:teammate,
                                       event: event,
                                       user: organizer_user,
                                       role: "organizer")
  }

  let(:reviewer_user) { create(:user) }
  let!(:reviewer_teammate) { create(:teammate,
                                      event: event,
                                      user: reviewer_user,
                                      role: "reviewer")
  }

  let(:program_team_user) { create(:user) }
  let!(:program_team_teammate) { create(:teammate,
                                      event: event,
                                      user: program_team_user,
                                      role: "program team")
  }

  context "An admin organizer" do
    before { login_as(admin_user) }

    it "can edit event guidelines", js: true do
      visit event_staff_guidelines_path(event)

      expect(page).to have_button "Edit Guidelines"
      expect(page).to have_content "We want all the good talks!"
      expect(page).to_not have_button "Save Guidelines"
      expect(page).to_not have_link "Cancel"

      click_on "Edit Guidelines"
      fill_in "text-box", with: "New Guidelines!"
      click_on "Save Guidelines"

      expect(page).to have_content "New Guidelines!"
      expect(page).to have_button "Edit Guidelines"

      click_on "Edit Guidelines"
      fill_in "text-box", with: "BLARG"
      click_on "Cancel"

      expect(page).to have_content "New Guidelines!"
    end
  end

  context "An organizer" do
    before { login_as(organizer_user) }

    it "can edit event guidelines", js: true do
      visit event_staff_guidelines_path(event)

      expect(page).to have_button "Edit Guidelines"
      expect(page).to have_content "We want all the good talks!"
      expect(page).to_not have_button "Save Guidelines"
      expect(page).to_not have_link "Cancel"

      click_on "Edit Guidelines"
      fill_in "text-box", with: "New Guidelines!"
      click_on "Save Guidelines"

      expect(page).to have_content "New Guidelines!"
      expect(page).to have_button "Edit Guidelines"

      click_on "Edit Guidelines"
      fill_in "text-box", with: "BLARG"
      click_on "Cancel"

      expect(page).to have_content "New Guidelines!"
    end
  end

  context "A reviewer" do
    before { login_as(reviewer_user) }

    it "cannot edit event guidelines", js: true do
      visit event_staff_guidelines_path(event)

      expect(page).to_not have_button "Edit Guidelines"
      expect(page).to have_content "We want all the good talks!"
    end
  end

  context "A program team" do
    before { login_as(program_team_user) }

    it "cannot edit event guidelines", js: true do
      visit event_staff_guidelines_path(event)

      expect(page).to_not have_button "Edit Guidelines"
      expect(page).to have_content "We want all the good talks!"
    end
  end

end
