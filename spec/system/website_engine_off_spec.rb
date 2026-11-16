require 'rails_helper'

RSpec.describe 'With the website engine switched off', type: :system do
  before { skip 'the website engine is loaded' if defined?(CfpWebsite) }

  let(:event) { create(:event) }
  let(:organizer) { create(:organizer, event: event) }

  before { login_as(organizer) }

  it 'shows no Website item in the navbar' do
    visit event_staff_path(event)
    expect(page).to have_link('Dashboard')
    expect(page).not_to have_link('Website')
  end

  it 'has no website staff routes' do
    visit "/events/#{event.slug}/staff/website/edit"
    expect(page.status_code).to eq(404)
  end

  it 'offers no sponsor field on the time slot form' do
    visit new_event_staff_schedule_time_slot_path(event)
    expect(page).to have_field('time_slot_title')
    expect(page).not_to have_select('time_slot_sponsor_id')
  end

  it 'lists time slots that still carry a sponsor_id' do
    room = create(:room, event: event)
    create(:time_slot, event: event, room: room).update_column(:sponsor_id, 42)
    visit event_staff_schedule_time_slots_path(event)
    expect(page).to have_css('tbody tr', count: 1)
    expect(page).not_to have_css('th', text: 'Sponsor')
  end
end
