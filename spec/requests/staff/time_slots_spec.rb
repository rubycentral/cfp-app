require 'rails_helper'

RSpec.describe 'Staff time slots', type: :request do
  let(:event) { create(:event) }
  let(:organizer) { create(:organizer, event: event) }

  before { sign_in(organizer) }

  describe 'GET index.json' do
    it 'exports the schedule, describing scheduled slots by their session' do
      room = create(:room, event: event, name: 'Main Hall', grid_position: 1)
      track = create(:track, event: event, name: 'Hardware')
      session = create(:program_session, event: event, title: 'Keynote', abstract: 'All about keys', track: track)
      create(:speaker, program_session: session, event: event, speaker_name: 'Ada')
      create(:time_slot, event: event, room: room, conference_day: 1, start_time: '10:00', end_time: '11:00', program_session: session)
      create(:time_slot, event: event, room: room, conference_day: 1, start_time: '12:00', end_time: '13:00',
             title: 'Lunch', presenter: 'Catering', description: 'Buffet')

      get event_staff_schedule_time_slots_path(event, format: :json)

      expect(response.headers['Content-Disposition']).to include("#{event.slug}-schedule-#{Time.current.to_fs(:db_just_date)}.json")
      expect(JSON.parse(response.body)).to eq([
        {'conference_day' => 1, 'start_time' => '10:00', 'end_time' => '11:00', 'program_session_id' => session.id,
         'title' => 'Keynote', 'presenter' => 'Ada', 'room' => 'Main Hall', 'track' => 'Hardware', 'description' => 'All about keys'},
        {'conference_day' => 1, 'start_time' => '12:00', 'end_time' => '13:00', 'program_session_id' => nil,
         'title' => 'Lunch', 'presenter' => 'Catering', 'room' => 'Main Hall', 'track' => nil, 'description' => 'Buffet'},
      ])
    end
  end
end
