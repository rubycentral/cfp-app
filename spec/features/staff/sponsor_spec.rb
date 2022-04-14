require 'rails_helper'

feature 'Event Sponsors' do
  let(:event) { create(:event, name: 'My Event') }
  let(:organizer) { create(:organizer, event: event) }

  context 'An admin organizer' do
    before { login_as(organizer) }

    it 'can create an event sponsor', js: true do
      visit event_staff_sponsors_path(event)
      expect(page).to have_link 'New Sponsor'

      click_on 'New Sponsor'
      fill_in 'sponsor_name', with: 'Fake Sponsor'

      click_on 'Save'
      expect(Sponsor.last.name).to eq('Fake Sponsor')
    end

    it 'can edit a sponsor', js: true do
      sponsor = create(:sponsor, event: event)
      visit edit_event_staff_sponsor_path(event, sponsor)
      fill_in 'sponsor_name', with: 'New Sponsor Name'
      click_on 'Save'

      expect(Sponsor.last.name).to eq('New Sponsor Name')
    end

    it 'can delete an event sponsor', js: true do
      sponsor = create(:sponsor, event: event)
      visit edit_event_staff_sponsor_path(event, sponsor)

      click_on 'Delete Sponsor'
      page.driver.browser.switch_to.alert.accept
      sleep 1
      expect(event.sponsors.count).to eq(0)
    end
  end

end
