require 'rails_helper'

feature 'Public Page Viewing', type: :system do
  let(:event) { create(:event) }
  let!(:website) { create(:website, event: event) }

  scenario 'Public views a published website page' do
    home_page = create(:page, published_body: 'Home Content')
    website.update(navigation_links: [home_page.slug])
    visit page_path(slug: event.slug, page: home_page.slug)

    expect(page).to have_content('Home Content')
    within('#main-nav') { expect(page).to have_content(home_page.name) }
  end

  scenario 'Public views the landing page of website' do
    create(:page, published_body: 'Home Content', landing: true)
    visit landing_path(slug: event.slug)

    expect(page).to have_content('Home Content')
  end

  context 'when using a custom domain' do
    xscenario 'Public views the landing page from custom domain' do
      website.update(domains: 'www.example.com')
      create(:page, published_body: 'Home Content', landing: true)
      visit root_path

      expect(page).to have_content('Home Content')
    end

    xscenario 'Public views the landing page for an older website on custom domain' do
      website.update(domains: 'www.example.com')
      old_home_page = create(:page, published_body: 'Old Website', landing: true)
      website.update(navigation_links: [old_home_page.slug])

      new_website = create(:website, domains: 'www.example.com')
      new_home_page = create(:page,
                             website: new_website,
                             published_body: 'New Website',
                             landing: true)

      new_website.update(navigation_links: [new_home_page.slug])
      visit root_path
      expect(page).to have_content('New Website')

      click_on(new_home_page.name, match: :first)
      expect(page).to have_content('New Website')

      visit landing_path(slug: website.event.slug)
      expect(page).to have_content('Old Website')

      click_on(old_home_page.name, match: :first)
      expect(page).to have_content('Old Website')
    end

    scenario 'Public gets not found message for wrong path on subdomain' do
      website.update(domains: 'www.example.com')

      visit landing_path(slug: website.event.slug)
      expect(page).to have_content("Page Not Found")
    end
  end
end
