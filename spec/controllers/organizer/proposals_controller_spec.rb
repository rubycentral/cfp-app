require 'rails_helper'

describe Organizer::ProposalsController, type: :controller do

  let(:event) { create(:event) }
  let(:person) do
    create(:person,
           organizer_participants:
             [ build(:participant, role: 'organizer', event: event) ],
          )
  end
  let(:proposal) { create(:proposal, event: event) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(person)
  end

  describe "POST 'update_state'" do
    it "returns http redirect" do
      post 'update_state', event_id: event.id, proposal_uuid: proposal.uuid
      expect(response).to redirect_to(organizer_event_proposals_path(event))
    end
  end

  describe "POST 'finalize'" do
    it "returns http redirect" do
      post :finalize, event_id: event.id, proposal_uuid: proposal.uuid
      expect(response).to redirect_to(organizer_event_proposal_path(event, proposal))
    end

    it "finalizes the state" do
      proposal = create(:proposal, event: event, state: Proposal::State::SOFT_ACCEPTED)
      post :finalize, event_id: event.id, proposal_uuid: proposal.uuid
      expect(assigns(:proposal).state).to eq(Proposal::State::ACCEPTED)
    end

    it "sends appropriate emails" do
      state_to_email = {
        Proposal::State::SOFT_ACCEPTED => :accept_email,
        Proposal::State::SOFT_WAITLISTED => :waitlist_email,
        Proposal::State::SOFT_REJECTED => :reject_email
      }

      state_to_email.each do |state, mail_action|
        proposal = create(:proposal, state: state)
        mail = double(:mail, deliver: nil)
        expect(Organizer::ProposalMailer).to receive(mail_action).and_return(mail)
        post :finalize, event_id: event.id, proposal_uuid: proposal.uuid
      end
    end
  end
end
