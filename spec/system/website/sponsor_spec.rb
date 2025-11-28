require 'rails_helper'

feature 'Wesite displays an events sponsors', type: :system do
  let(:event) { create(:event, name: 'My Event') }
  let!(:website) { create(:website, event: event) }
  let(:organizer) { create(:organizer, event: event) }

  context 'Website sponsor page' do
    before { login_as(organizer) }

    it 'Website sponsor page reflects updates to event sponsors', js: true do
      sponsor = create(:sponsor, published: false)

      visit sponsors_path(event)
      expect(page).to_not have_content(sponsor.description)

      sponsor.update(published: true)
      visit sponsors_path(event)
      expect(page).to have_content(sponsor.description)
      expect(page).to have_css("img[src*='ruby1.png']")

      sponsor.destroy
      visit sponsors_path(event)
      expect(page).to_not have_content(sponsor.description)
      expect(page).to_not have_css("img[src*='ruby1.png']")
    end

    it 'Website pages can display a sponsors footer', js: true do
      create(:sponsor, :with_footer_logo)
      home_page = create(:page, published_body: "Home")

      visit sponsors_path(event)
      expect(page).to have_css("img[src*='ruby1.png']")

      visit page_path(event, page: home_page.slug)
      expect(page).to_not have_css("img[src*='ruby1.png']")

      sponsors_footer_element = "<sponsors-footer></sponsors-footer>"

      home_page.update(published_body: sponsors_footer_element)
      visit page_path(event, page: home_page.slug)
      expect(page).to_not have_css("img[src*='ruby1.png']")
      expect(page).to have_css("img[src*='ruby2.jpeg']")
    end

    it "Sponsors footer displays a sponsor offer on click if sponsor has offer available", js: true do
      pending 'Not passing'

      sponsor = create(:sponsor, :with_footer_logo, :with_offer)
      sponsors_footer_element = "<sponsors-footer></sponsors-footer>"
      home_page = create(:page, published_body: sponsors_footer_element)

      visit page_path(event, page: home_page.slug)
      expect(page).to_not have_content(sponsor.offer_text)
      expect(page).to_not have_content(sponsor.offer_headline)

      find('.sponsor-offer-reveal-button').click
      expect(page).to have_content(sponsor.offer_text)
      expect(page).to have_content(sponsor.offer_headline)

      find('.sponsor-offer-reveal-button').click
      expect(page).to_not have_content(sponsor.offer_text)
      expect(page).to_not have_content(sponsor.offer_headline)
    end

    it "Sponsor page doesn't display sponsors from a different event", js: true do
      previous_event = create(:event, name: 'My Older Event')
      previous_sponsor = create(:sponsor, event: previous_event, name: "Previous Sponsor", tier: "Gold")

      sponsor = create(:sponsor)
      visit sponsors_path(event)

      expect(page).to have_content(sponsor.description)
      expect(page).to_not have_content(previous_sponsor.description)
    end
  end
end
