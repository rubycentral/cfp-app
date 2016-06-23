require 'rails_helper'

describe Reviewer::ProposalsController, type: :controller do

  let(:proposal) { create(:proposal) }
  let(:event) { proposal.event }
  let(:reviewer) { create(:user, :reviewer) }
  let(:speaker) { create(:speaker, proposal: proposal) }


  before { sign_in(reviewer) }

  describe "GET 'show'" do
    it "marks all notifications for this proposal as read" do
      Notification.create_for([reviewer], proposal: proposal, message: "A fancy notification")
      expect{
        get :show, {event_id: event.id, uuid: proposal.uuid}
      }.to change {reviewer.notifications.unread.count}.by(-1)
    end
  end

  describe '#index' do
    it "should respond" do
      get :index, event_id: proposal.event.id
      expect(response.status).to eq(200)
    end
  end

  context "reviewer has a submitted proposal" do
    let!(:speaker) { create(:speaker, user: reviewer) }
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
