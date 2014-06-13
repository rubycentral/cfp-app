require 'rails_helper'

describe Reviewer::RatingsController, type: :controller do
  let(:proposal) { create(:proposal) }
  let(:event) { proposal.event }
  let(:reviewer) { create(:person, :reviewer) }
  let!(:speaker) { create(:speaker, proposal: proposal) }

  before { login reviewer }

  context "reviewer has a submitted proposal" do
    let!(:speaker) { create(:speaker, person: reviewer) }
    let!(:proposal) { create(:proposal, speakers: [ speaker ]) }

    it "prevents reviewer from rating their own proposals" do
      expect {
        xhr :post, :create, event_id: event, proposal_uuid: proposal,
          rating: { score: 3 }
      }.to_not change { Rating.count }
    end
  end
end
