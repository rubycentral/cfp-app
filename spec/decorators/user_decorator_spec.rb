require 'rails_helper'

describe UserDecorator do
  describe "#proposal_path" do
    it "returns the path for a speaker" do
      speaker = create(:speaker)
      proposal = create(:proposal, speakers: [ speaker ])
      expect(speaker.user.decorate.proposal_path(proposal)).to(
        eq(h.event_staff_proposal_path(proposal.event.slug, proposal)))
    end

    it "returns the path for a reviewer" do
      reviewer = create(:user, :reviewer)
      proposal = create(:proposal)
      expect(reviewer.decorate.proposal_path(proposal)).to(
        eq(h.event_staff_proposal_path(proposal.event, proposal)))
    end
  end
end
