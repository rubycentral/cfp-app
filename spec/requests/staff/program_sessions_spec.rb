require 'rails_helper'

RSpec.describe 'Staff program sessions', type: :request do
  let(:event) { create(:event) }
  let(:organizer) { create(:organizer, event: event) }

  before { sign_in(organizer) }

  describe 'GET index.json' do
    it 'exports the live sessions with their speakers' do
      track = create(:track, event: event, name: 'Hardware')
      session_format = create(:session_format, event: event, name: 'Talk')
      live = create(:program_session, event: event, title: 'Keynote', abstract: 'All about keys', track: track,
                    session_format: session_format, video_url: 'https://example.com/v', slides_url: 'https://example.com/s')
      create(:speaker, program_session: live, event: event, speaker_name: 'Ada', bio: 'Mathematician')
      create(:program_session, event: event, state: :draft, title: 'Not yet')

      get event_staff_program_sessions_path(event, format: :json)

      expect(response.headers['Content-Disposition']).to include("#{event.slug}-program-#{Time.current.to_fs(:db_just_date)}.json")
      sessions = JSON.parse(response.body)
      expect(sessions.map { |s| s['title'] }).to eq(['Keynote'])
      expect(sessions.first).to include(
        'id' => live.id, 'abstract' => 'All about keys', 'format' => 'Talk', 'track' => 'Hardware',
        'video_url' => 'https://example.com/v', 'slides_url' => 'https://example.com/s',
        'speakers' => [{'name' => 'Ada', 'bio' => 'Mathematician'}]
      )
    end
  end
end
