require 'rails_helper'

describe UserDecorator do

  describe "#proposal_notification_url" do

    it "returns the proposal url for a speaker" do
      speaker = create(:speaker)
      proposal = create(:proposal, speakers: [ speaker ])
      expect(speaker.user.decorate.proposal_notification_url(proposal)).to(
        eq(h.event_proposal_url(proposal.event.slug, proposal)))
    end

    it "returns the proposal url for a reviewer" do
      reviewer = create(:user, :reviewer)
      proposal = create(:proposal)
      expect(reviewer.decorate.proposal_notification_url(proposal)).to(
        eq(h.event_staff_proposal_url(proposal.event, proposal)))
    end
  end
end
