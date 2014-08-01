require 'rails_helper'

describe PersonDecorator do
  describe "#proposal_path" do
    it "returns the regular path for a speaker" do
      speaker = create(:speaker)
      proposal = create(:proposal, speakers: [ speaker ])
      expect(speaker.person.decorate.proposal_path(proposal)).to(
        eq(h.proposal_path(proposal.event.slug, proposal)))
    end

    it "returns the reviewer path for an organizer" do
      organizer = create(:organizer)
      proposal = create(:proposal)
      expect(organizer.decorate.proposal_path(proposal)).to(
        eq(h.reviewer_event_proposal_path(proposal.event, proposal)))
    end

    it "returns the reviewer path for a reviewer" do
      reviewer = create(:person, :reviewer)
      proposal = create(:proposal)
      expect(reviewer.decorate.proposal_path(proposal)).to(
        eq(h.reviewer_event_proposal_path(proposal.event, proposal)))
    end
  end
end
