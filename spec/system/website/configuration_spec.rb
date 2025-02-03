require 'rails_helper'

include ActionView::Helpers::SanitizeHelper
feature "Website Configuration", type: :system do
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

  scenario "Organizer configures domain for an existing website for event", :js do
    website = create(:website, event: event)
    home_page = create(:page, website: website)

    visit("/#{home_page.slug}")

    expect(current_path).to eq(not_found_path)

    login_as(organizer)
    visit event_path(website.event)
    within('.navbar') { click_on("Website") }

    expect(page).to have_content("Edit Website")

    fill_in('Domains', with: 'www.example.com')
    fill_in('Navigation links', with: "Home\n")
    click_on("Save")

    expect(page).to have_content("Website was successfully updated")

    logout

    visit("/#{home_page.slug}")

    expect(page).to have_content(strip_tags(home_page.published_body))

    click_on(home_page.name, match: :first)

    expect(current_path).to eq("/#{home_page.slug}")
  end

  scenario "Organizer fails to add font file correctly", :js do
    website = create(:website, event: event)

    login_as(organizer)
    visit edit_event_staff_website_path(event)

    click_on("Add Font")
    click_on("Save")
    expect(page).to have_content("Website was successfully updated")

    expect(website.fonts.count).to eq(0)

    click_on("Add Font")
    within(".nested-fonts") { fill_in("Name", with: "Times") }
    click_on("Save")

    expect(page).to have_content("There were errors updating your website configuration")
    within(".nested-fonts") { expect(page).to have_content("can't be blank") }
  end

  scenario "Organizer configures tailwind with head content", :js do
    skip "FactoryBot 😤"
    website = create(:website, event: event)
    home_page = create(:page, website: website)

    login_as(organizer)
    visit edit_event_staff_website_path(event)
    click_on("Add Content")
    fill_in_codemirror(<<~HTML
      <script>
        tailwind.config = {
          theme: {
            extend: {
              colors: {
                clifford: '#da373d',
              }
            }
          }
        }
      </script>
      HTML
    )
    fill_in("City", with: "Big Red")
    click_on("Save")

    visit edit_event_staff_page_path(event, home_page)
    fill_in_codemirror(
      '<div class="text-clifford" id="red-dog">Clifford The Big Red Dog</div>'
    )
    click_on("Save")
    accept_confirm { click_on("Publish") }
    click_on("View")

    expect(computed_style("#red-dog", "color")).to eq("rgb(218, 55, 61)")
  end

  scenario "Organizer adjusts website caching", :caching do
    skip "FactoryBot 😤"
    fastly_service = spy("fastly_service")
    allow(FastlyService).to receive(:service).and_return fastly_service
    website = create(:website, event: event)
    home_page = create(:page, website: website, published_body: 'Home Content')

    visit page_path(event, home_page)
    expect(response_headers["Cache-Control"]).to eq("max-age=0, private, s-maxage=0")

    login_as(organizer)
    visit edit_event_staff_website_path(event)

    select("automatic", from: "Caching")
    click_on("Save")

    visit page_path(event, home_page)
    expect(response_headers["Cache-Control"]).to eq("max-age=0, public, s-maxage=604800")
    expect(response_headers["Surrogate-Key"]).to eq(event.slug)
    last_modified = response_headers["Last-Modified"]

    visit page_path(event, home_page)
    expect(response_headers["Last-Modified"]).to eq(last_modified)

    RSpec::Mocks.space.proxy_for(fastly_service).reset
    sleep 1
    visit event_staff_pages_path(event)
    click_on("Publish")
    expect(fastly_service).to have_received(:purge_by_key).with(event.slug)

    visit page_path(event, home_page)
    expect(response_headers["Last-Modified"]).not_to eq(last_modified)

    visit edit_event_staff_website_path(event)

    select("manual", from: "Caching")
    click_on("Save")

    visit page_path(event, home_page)
    expect(response_headers["Cache-Control"]).to eq("max-age=0, public, s-maxage=604800")
    expect(response_headers["Surrogate-Key"]).to eq(event.slug)
    last_modified = response_headers["Last-Modified"]

    RSpec::Mocks.space.proxy_for(fastly_service).reset
    sleep 1
    visit event_staff_pages_path(event)
    click_on("Publish")
    expect(fastly_service).not_to have_received(:purge_by_key).with(event.slug)

    visit page_path(event, home_page)
    expect(response_headers["Last-Modified"]).to eq(last_modified)

    visit edit_event_staff_website_path(event)
    click_on("Purge")

    visit page_path(event, home_page)
    expect(response_headers["Last-Modified"]).not_to eq(last_modified)
  end
end
