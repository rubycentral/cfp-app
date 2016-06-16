require 'rails_helper'

feature "A user only sees information for the current event" do
  let!(:normal_user) { create(:user) }

  scenario "User flow for a speaker when there is a live event" do
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

    find("h1").click
    expect(current_path).to eq(event_path(event_1.slug))
    within ".navbar" do
      expect(page).to have_content(event_1.name)
    end

    expect(current_event.id).to eq(1)
  end

  scenario "User flow for a speaker when there is no live event" do
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
    expect(current_path).to eq(event_path(event_2.slug))
    within ".navbar" do
      expect(page).to have_content(event_2.name)
    end
  end

  scenario "User flow for a reviewer when there is a live event" do

  end

  scenario "User flow for a reviewer when there is a no live event" do

  end

  scenario "User flow for a organizer when there is a live event" do

  end

  scenario "User flow for a organizer when there is a no live event" do

  end

  scenario "User flow for a admin when there is a live event" do

  end

  scenario "User flow for a admin when there is a no live event" do

  end
end
