require 'rails_helper'

describe Organizer::SessionsController, type: :controller do
  let(:event) { create(:event) }
  before { login(create(:organizer, event: event)) }

  describe "DELETE 'destroy'" do
    it "destroys the session" do
      conf_session = create(:session, event: event)
      expect {
        xhr :delete, :destroy, id: conf_session, event_id: conf_session.event
      }.to change(Session, :count).by(-1)
    end
  end

  describe "PUT 'update'" do
    it "can update a session with ajax" do
      conf_session = create(:session, conference_day: 3, event: event)
      xhr :put, :update, id: conf_session, event_id: conf_session.event,
        session: { conference_day: 5 }
      expect(assigns(:session).conference_day).to eq(5)
      expect(response).to be_success
    end

    it "can set the proposal" do
      proposal = create(:proposal, event: event)
      conf_session = create(:session, event: proposal.event)
      xhr :put, :update, id: conf_session, event_id: conf_session.event,
        session: { proposal_id: proposal.id }
      expect(assigns(:session).proposal).to eq(proposal)
    end
  end

end
