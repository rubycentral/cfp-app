require 'rails_helper'

feature "Website Page Management" do
  let(:event) { create(:event) }
  let(:organizer) { create(:organizer, event: event) }
  let!(:website) { create(:website, event: event) }

  scenario "Organizer creates and edits a website page", :js do
    login_as(organizer)

    visit event_path(event)
    within('.navbar') { click_on("Website") }
    within('.website-subnav') { click_on("Pages") }
    click_on "New Page"

    click_on('Save')
    within('.page_name') { expect(page).to have_content("can't be blank") }
    within('.page_slug') { expect(page).to have_content("can't be blank") }

    fill_in('Name', with: 'Home')
    fill_in('Slug', with: 'home')
    fill_in_tinymce(:page, :unpublished_body, 'Come Code With Us')
    click_on('Save')

    expect(page).to have_content('Home Page was successfully created')

    click_on('Home')
    expect(page).to have_content('Edit Home Page')
    fill_in_tinymce(:page, :unpublished_body, :enter)
    fill_in_tinymce(:page, :unpublished_body, 'In Asheville, NC')
    click_on('Save')

    expect(page).to have_content('Home Page was successfully updated')
  end

  scenario "Organizer publishes a website page", :js do
    home_page = create(:page, unpublished_body: 'Home Content', published_body: nil)
    login_as(organizer)

    visit page_path(slug: event.slug, page: home_page.slug)
    expect(current_path).to eq('/404')
    visit event_staff_pages_path(event)
    accept_confirm { click_on('Publish') }

    expect(page).to have_content('Home Page was successfully published.')

    visit page_path(slug: event.slug, page: home_page.slug)
    expect(page).to have_content('Home Content')
    within('#main-nav') { expect(page).to have_content(home_page.name) }
  end

  scenario "Public views a published website page" do
    home_page = create(:page, published_body: 'Home Content')
    visit page_path(slug: event.slug, page: home_page.slug)
    expect(page).to have_content('Home Content')
    within('#main-nav') { expect(page).to have_content(home_page.name) }
  end

end
