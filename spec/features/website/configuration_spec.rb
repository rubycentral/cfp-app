require 'rails_helper'

feature "Website Configuration" do
  let(:event) { create(:event) }
  let(:organizer) { create(:organizer, event: event) }

  scenario "Organizer configures a new website for event" do
    login_as(organizer)

    visit event_path(event)
    within('.navbar') { click_on("Website") }
    click_on("Save")

    expect(page).to have_content("Website was successfully created")
    expect(event.website).to be_present
  end

  scenario "Organizer configures an existing website for event" do
    website = create(:website, event: event)
    login_as(organizer)

    visit event_path(website.event)
    within('.navbar') { click_on("Website") }

    expect(page).to have_content("Edit Website")

    click_on("Save")

    expect(page).to have_content("Website was successfully updated")
  end
end
