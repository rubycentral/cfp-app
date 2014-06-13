require 'rails_helper'

describe Reviewer::ProposalsController, type: :controller do

  let(:proposal) { create(:proposal) }
  let(:event) { proposal.event }
  let(:reviewer) { create(:person, :reviewer) }
  let!(:speaker) { create(:speaker, proposal: proposal) }

  before { login reviewer }

  describe '#index' do
    it "should respond" do
      get :index, event_id: proposal.event.id
      expect(response.status).to eq(200)
    end
  end

  context "reviewer has a submitted proposal" do
    let!(:speaker) { create(:speaker, person: reviewer) }
    let!(:proposal) { create(:proposal, speakers: [ speaker ]) }

    it "prevents reviewers from viewing their own proposals" do
      get :show, event_id: event, uuid: proposal
      expect(response).to redirect_to(reviewer_event_proposals_path)
    end

    it "prevents reviewers from updating their own proposals" do
      get :update, event_id: event, uuid: proposal,
        proposal: { review_tags: [ 'tag' ] }
      expect(proposal.review_tags).to_not eq([ 'tag' ])
    end
  end

end
