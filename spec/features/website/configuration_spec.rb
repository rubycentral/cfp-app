require 'rails_helper'

include ActionView::Helpers::SanitizeHelper
feature "Website Configuration" do
  let(:event) { create(:event) }
  let(:organizer) { create(:organizer, event: event) }

  scenario "Organizer creates a new website for event" do
    login_as(organizer)

    visit event_path(event)
    within('.navbar') { click_on("Website") }
    click_on("Save")

    expect(page).to have_content("Website was successfully created")
    expect(event.website).to be_present
  end

  scenario "Organizer configures domain for an existing website for event" do
    website = create(:website, event: event)
    home_page = create(:page, website: website)

    visit("/#{home_page.slug}")

    expect(current_path).to eq(not_found_path)

    login_as(organizer)
    visit event_path(website.event)
    within('.navbar') { click_on("Website") }

    expect(page).to have_content("Edit Website")

    fill_in('Domains', with: 'www.example.com')
    click_on("Save")

    expect(page).to have_content("Website was successfully updated")

    logout

    visit("/#{home_page.slug}")

    expect(page).to have_content(strip_tags(home_page.published_body))

    click_on(home_page.name)

    expect(current_path).to eq('/home')
  end
end
