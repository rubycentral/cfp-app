require 'rails_helper'

feature "Event Config" do
  let(:organizer_user) { create(:user) }
  let!(:organizer_teammate) { create(:teammate,
                                       user: organizer_user,
                                       role: "organizer")
  }

  let(:reviewer_user) { create(:user) }
  let!(:reviewer_event_teammate) { create(:teammate,
                                      user: reviewer_user,
                                      role: 'reviewer')
  }

  context "As an organizer", js: true do
    before :each do
      logout
      login_as(organizer_user)
    end

    it "can add a new session format" do
      visit event_staff_config_path(organizer_teammate.event)
      click_on "Add Session Format"

      fill_in "Name", with: "Best Session"
      click_button "Save"

      within('#session-formats') do
        expect(page).to have_content("Best Session")
      end
    end

    it "can edit a session format" do
      session_format = create(:session_format)
      visit event_staff_config_path(organizer_teammate.event)
      within("#session_format_#{session_format.id}") do
        click_on "Edit"
      end

      fill_in "Description", with: "The most exciting session."
      click_button "Save"

      within("#session_format_#{session_format.id}") do
        expect(page).to have_content("The most exciting session.")
      end
    end

    it "can add a new track" do
      visit event_staff_config_path(organizer_teammate.event)
      click_on "Add Track"

      fill_in "Name", with: "Best Track"
      click_button "Save"

      within('#tracks') do
        expect(page).to have_content("Best Track")
      end
    end

    it "can edit a track" do
      track = create(:track, event: organizer_teammate.event)
      visit event_staff_config_path(organizer_teammate.event)
      within("#track_#{track.id}") do
        click_on "Edit"
      end

      fill_in "Description", with: "The best track ever."
      click_button "Save"

      within("#track_#{track.id}") do
        expect(page).to have_content("The best track ever.")
      end
    end
  end

  context "As a reviewer", js: true do
    before :each do
      logout
      login_as(reviewer_user)
    end

    it "cannot view link to add new session format" do
      visit event_staff_config_path(reviewer_event_teammate.event)

      expect(page).to_not have_content("Add Session Format")
    end

    it "cannot view link to edit session format" do
      session_format = create(:session_format)
      visit event_staff_config_path(reviewer_event_teammate.event)

      within("#session_format_#{session_format.id}") do
        expect(page).to_not have_content("Edit")
      end
    end

    it "cannot view link to add new track" do
      visit event_staff_config_path(reviewer_event_teammate.event)

      expect(page).to_not have_content("Add Track")
    end

    it "cannot view link to edit track" do
      track = create(:track, event: reviewer_event_teammate.event)
      visit event_staff_config_path(reviewer_event_teammate.event)

      within("#track_#{track.id}") do
        expect(page).to_not have_content("Edit")
      end
    end
  end
end
