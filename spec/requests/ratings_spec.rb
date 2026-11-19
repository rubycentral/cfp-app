require 'rails_helper'

RSpec.describe 'Ratings', type: :request do
  let(:event) { create(:event) }
  let(:proposal) { create(:proposal_with_track, event: event) }
  let(:reviewer) { create(:reviewer, event: event) }

  before { sign_in(reviewer) }

  it 'lets a reviewer rate a proposal' do
    expect {
      post event_staff_proposal_ratings_path(event, proposal), params: {rating: {score: 3}}, as: :turbo_stream
    }.to change(Rating, :count).by(1)
    expect(Rating.last).to have_attributes(user: reviewer, proposal: proposal, score: 3)
  end

  it 'refuses to let a reviewer rate their own proposal' do
    create(:speaker, proposal: proposal, user: reviewer)

    expect {
      post event_staff_proposal_ratings_path(event, proposal), params: {rating: {score: 3}}, as: :turbo_stream
    }.not_to change(Rating, :count)
    expect(response).to redirect_to(event_staff_proposals_url(event))
    expect(flash[:notice]).to eq("Can't review your own proposal!")
  end
end
