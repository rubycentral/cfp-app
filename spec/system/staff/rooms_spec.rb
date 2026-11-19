require 'rails_helper'

feature 'Staff Organizers can manage rooms', type: :system do
  let(:event) { create(:event) }
  let!(:organizer_user) { create(:organizer, event: event) }

  before { login_as(organizer_user) }

  scenario 'removes a room', js: true do
    room = create(:room, name: 'Main Hall', event: event)
    visit event_staff_schedule_rooms_path(event)

    within("#room_#{room.id}") do
      accept_confirm { click_on 'Remove' }
    end

    expect(page).not_to have_css("#room_#{room.id}")
    expect(Room.exists?(room.id)).to be false
  end
end
