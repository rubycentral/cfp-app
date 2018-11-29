require 'rails_helper'

describe Staff::RatingsController, type: :controller do
  let(:proposal) { create(:proposal) }
  let(:event) { proposal.event }
  let(:reviewer) { create(:user, :reviewer) }
  let!(:speaker) { create(:speaker, proposal: proposal) }

  before { sign_in(reviewer) }

  context "reviewer has a submitted proposal" do
    let!(:speaker) { create(:speaker, user: reviewer) }
    let!(:proposal) { create(:proposal, speakers: [ speaker ]) }

    it "prevents reviewer from rating their own proposals" do
      expect {
        post :create, xhr: true, params: {event_slug: event.slug, proposal_uuid: proposal, rating: { score: 3 }}
      }.to_not change { Rating.count }
    end
  end
end
