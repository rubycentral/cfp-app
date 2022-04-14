require 'rails_helper'

feature "Public Page Viewing" do
  let(:event) { create(:event) }
  let!(:website) { create(:website, event: event) }

  scenario "Public views a published website page" do
    home_page = create(:page, published_body: 'Home Content')
    visit page_path(slug: event.slug, page: home_page.slug)
    expect(page).to have_content('Home Content')
    within('#main-nav') { expect(page).to have_content(home_page.name) }
  end
end
