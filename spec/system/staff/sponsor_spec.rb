require 'rails_helper'

feature 'Event Sponsors', type: :system do
  let(:event) { create(:event, name: 'My Event') }
  let(:organizer) { create(:organizer, event: event) }

  context 'An admin organizer' do
    before { login_as(organizer) }

    it 'can create an event sponsor with images', js: true do
      visit event_staff_sponsors_path(event)
      expect(page).to have_link 'New Sponsor'

      click_on 'New Sponsor'

      fill_in 'sponsor_name', with: 'Fake Sponsor'
      fill_in 'sponsor_url', with: 'https://www.fakeurl.com'
      fill_in 'sponsor_description', with: "Brief Description"
      select Sponsor::TIERS.first, from: "sponsor_tier"

      attach_file('sponsor_primary_logo', Rails.root.join('spec/fixtures/files/ruby1.png'))
      attach_file('sponsor_footer_logo', Rails.root.join('spec/fixtures/files/ruby2.jpeg'))
      attach_file('sponsor_banner_ad', Rails.root.join('spec/fixtures/files/ruby3.png'))

      click_on 'Save'

      expect(page).to have_content('Fake Sponsor')
      expect(page).to have_content(Sponsor::TIERS.first)

      click_on 'Edit Sponsor'
      expect(page).to have_css("img[src*='ruby1.png']")
      expect(page).to have_css("img[src*='ruby2.jpeg']")
      expect(page).to have_css("img[src*='ruby3.png']")
    end

    it 'can edit a sponsor' do
      sponsor = create(:sponsor, event: event)
      visit edit_event_staff_sponsor_path(event, sponsor)

      fill_in 'sponsor_name', with: 'New Sponsor Name'
      attach_file('sponsor_primary_logo', Rails.root.join('spec/fixtures/files/ruby1.png'))

      click_on 'Save'
      expect(Sponsor.last.name).to eq('New Sponsor Name')

      click_on 'Edit Sponsor'
      expect(page).to have_css("img[src*='ruby1.png']")
    end

    it 'can delete an event sponsor', js: true do
      sponsor = create(:sponsor, event: event)
      visit edit_event_staff_sponsor_path(event, sponsor)

      accept_confirm { click_on 'Delete Sponsor' }
      expect(page).to have_content('Sponsor was successfully removed.')
      expect(event.sponsors.count).to eq(0)
    end

    it 'sponsons are listed in tier order on the index page' do
      Sponsor::TIERS.each { |tier| create(:sponsor, tier: tier) }
      visit event_staff_sponsors_path(event)

      expect(page).to have_content(/diamond.*platinum.*gold.*silver.*bronze.*other.*supporter/)
    end
  end
end
