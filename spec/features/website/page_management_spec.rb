require 'rails_helper'

feature "Website Page Management" do
  let(:event) { create(:event) }
  let(:organizer) { create(:organizer, event: event) }

  scenario "Organizer creates and edits a website page", :js do
    create(:website, event: event)
    login_as(organizer)

    visit event_path(event)
    within('.navbar') { click_on("Website") }
    within('.website-subnav') { click_on("Pages") }
    click_on "New Page"

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
end
