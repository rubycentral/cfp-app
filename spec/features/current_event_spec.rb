require 'rails_helper'

feature "A user only sees information for the currently selected event" do
  let!(:normal_user) { create(:user) }

  scenario "User flow when there is a live event" do
    event_1 = create(:event, state: 'open')
    event_2 = create(:event, state: 'closed')

    visit root_path
    login_user(normal_user)
    save_and_open_page
    # fill_in "email"

    within ".navbar" do
      expect(page).to have_link(event_1.name)
      expect(page).to have_content("Notifications")
      expect(page).to have_link(normal_user.name)
    end
  end

  scenario "User flow when there is no live event" do

  end
end
