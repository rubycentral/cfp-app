require 'rails_helper'

RSpec.describe Page do
  describe '.promote' do
    let!(:page) { create(:page, website: create(:website)) }
    it 'promotes the website page to be the landing page' do
      Page.promote(page)
      expect(page).to be_landing
    end

    it 'demotes the other website pages from being the landing page' do
      other_page = create(:page, landing: true)
      expect { Page.promote(page) }
        .to change { page.landing }.from(false).to(true)
        .and change { other_page.reload.landing }.from(true).to(false)
    end

    it 'does not affect other website landing pages' do
      other_page = create(:page, landing: true, website: create(:website))
      expect { Page.promote(page) }
        .to change { page.landing }.from(false).to(true)
      expect(other_page.reload).to be_landing
    end
  end
end
