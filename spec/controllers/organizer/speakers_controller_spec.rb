require 'rails_helper'

describe Organizer::SpeakersController, type: :controller do
  let(:event) { create(:event) }

  describe "GET 'speaker_emails'" do
    render_views

    it "returns a list of speaker emails" do
      proposal = create(:proposal, event: event)
      speakers = create_list(:speaker, 5, proposal: proposal)
      login(create(:organizer, event: event))
      xhr :get, :emails, event_id: event, proposal_ids: [ proposal.id ]
      speakers.each do |speaker|
        expect(response.body).to match(speaker.email)
      end
    end
  end
end
