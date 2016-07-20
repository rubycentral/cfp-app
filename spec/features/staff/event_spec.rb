require 'rails_helper'

feature "Event Dashboard" do
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

  context "As an organizer" do
    before :each do
      logout
      login_as(organizer_user)
    end

    it "cannot create new events" do
      # pending "This fails because it sends them to login and then Devise sends to events path and changes flash"
      visit new_admin_event_path
      expect(page.current_path).to eq(events_path)
      #Losing the flash on redirect here.
      # expect(page).to have_text("You must be signed in as an administrator")
    end

    it "can edit events" do
      visit event_staff_edit_path(organizer_teammate.event)
      fill_in "Name", with: "Blef"
      click_button 'Save'
      expect(page).to have_text("Blef")
    end

    it "can change event status" do
      visit event_staff_info_path(organizer_teammate.event)

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
      visit event_staff_url(organizer_teammate.event)
      expect(page).not_to have_link('Delete Event')
    end
  end
end
