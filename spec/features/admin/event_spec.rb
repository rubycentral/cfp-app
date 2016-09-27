require "rails_helper"

feature "Event Dashboard" do
  let(:event) { create(:event, name: "My Event") }
  let(:admin_user) { create(:user, admin: true) }
  let!(:admin_teammate) { create(:teammate,
                                   event: event,
                                   user: admin_user,
                                   role: "organizer"
                                  )
  }

  context "An admin" do
    before { login_as(admin_user) }

    it "can create a new event and becomes an organizer" do
      visit new_admin_event_path
      fill_in "Name", with: "My Other Event"
      fill_in "Slug", with: "otherevent"
      fill_in "Contact email", with: "me@example.com"
      fill_in "Start date", with: DateTime.now + 10.days
      fill_in "End date", with: DateTime.now + 15.days
      fill_in "Closes at", with: DateTime.now + 15.days
      click_button "Save"

      event = Event.last
      expect(admin_user.organizer_for_event?(event)).to be(true)
    end

    it "must provide correct url syntax if a url is given" do
      visit new_admin_event_path
      fill_in "Name", with: "All About Donut Holes"
      fill_in "Slug", with: "donutholes"
      fill_in "URL", with: "www.donutholes.com"
      click_button "Save"

      expect(page).to have_content "must start with http:// or https://"
    end

    it "can edit an event" do
      visit event_staff_edit_path(event)
      fill_in "Name", with: "My Finest Event Evar For Realz"
      click_button "Save"
      expect(page).to have_text("My Finest Event Evar For Realz")
    end

    it "can delete events" do
      skip "pending admin delete permissions discussion"
      visit event_staff_edit_path(event)
      click_link "Delete Event"
      expect(page).not_to have_text("My Event")
    end
  end
end
