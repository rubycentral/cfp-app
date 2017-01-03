require 'rails_helper'

describe Staff::ProgramSessionsController, type: :controller do
  let(:event) { create(:event) }

  describe "GET 'speaker_emails'" do
    render_views

    it "returns a list of speaker emails" do
      ps = create(:program_session, event: event)
      speakers = create_list(:speaker, 5, :with_name, :with_email, program_session: ps)
      sign_in(create(:organizer, event: event))
      get :speaker_emails, xhr: true, params: {event_slug: event, session_ids: [ ps.id ]}
      speakers.each do |speaker|
        expect(response.body).to match(speaker.email)
      end
    end
  end
end
