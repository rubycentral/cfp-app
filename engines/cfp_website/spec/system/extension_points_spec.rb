require 'rails_helper'

RSpec.describe 'Website engine extension points', type: :system do
  let(:event) { create(:event) }
  let(:organizer) { create(:organizer, event: event) }

  before { login_as(organizer) }

  it 'adds the Website item to the navbar' do
    visit event_staff_path(event)
    expect(page).to have_link('Website', href: new_event_staff_website_path(event))
  end

  it 'marks the Website item active on website pages' do
    create(:website, event: event)
    visit edit_event_staff_website_path(event)
    expect(page).to have_css('.navbar-nav .nav-item.active', text: 'Website')
  end

  it 'adds the sponsor select to the time slot form' do
    visit new_event_staff_schedule_time_slot_path(event)
    expect(page).to have_select('time_slot_sponsor_id')
  end

  it 'shows the website subnav with the current item active on the pages index' do
    create(:website, event: event)
    visit event_staff_pages_path(event)
    expect(page).to have_css('.website-subnav .nav-item.active', text: 'Pages')
    expect(page).to have_css('.website-subnav .nav-item', text: 'Configuration')
  end
end
