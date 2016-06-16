require 'rails_helper'

feature "A user only sees information for the current event" do
  let!(:normal_user) { create(:user) }

  scenario "User flow when there is a live event" do
    event_1 = create(:event, state: "open")
    event_2 = create(:event, state: "closed")

    signin(normal_user.email, normal_user.password)

    within ".navbar" do
      expect(page).to have_link(event_1.name)
      expect(page).to have_link("Notifications")
      expect(page).to have_link(normal_user.name)
    end

    expect(current_path).to eq(event_path(event_1.slug))

    expect(page).to have_link(event_1.name)
    expect(page).to_not have_link(event_2.name)
  end

  scenario "User flow when there is no live event" do
    event_1 = create(:event, state: "closed")
    event_2 = create(:event, state: "closed")

    signin(normal_user.email, normal_user.password)

    within ".navbar" do
      expect(page).to have_content("CFPApp")
      expect(page).to have_link("Notifications")
      expect(page).to have_link(normal_user.name)
    end

    expect(current_path).to eq(events_path)

    expect(page).to have_link(event_1.name)
    expect(page).to have_link(event_2.name)

    click_on event_2.name
    # expect(current_path).to eq()
  end
end
