require 'rails_helper'

describe ProposalDecorator do
  describe "#speaker_names" do
    it "returns speaker names as a comma separated string" do
      proposal = create(:proposal_with_track)
      speakers = create_list(:speaker, 3, proposal: proposal)
      names = proposal.decorate.speaker_names
      speakers.each do |speaker|
        expect(names).to match(speaker.name)
      end
    end
  end

  describe "#speaker_emails" do
    it "returns speaker emails as a comma separated string" do
      proposal = create(:proposal_with_track)
      speakers = create_list(:speaker, 3, proposal: proposal)
      emails = proposal.decorate.speaker_emails
      speakers.each do |speaker|
        expect(emails).to match(speaker.email)
      end
    end
  end

  describe "#state" do
    it "returns 'not accepted' for a rejected state" do
      proposal = create(:proposal_with_track, state: ProposalDecorator::REJECTED)
      expect(proposal.decorate.state).to eq(ProposalDecorator::NOT_ACCEPTED)
    end

    it "returns the current state for non-rejected states" do
      states = [
        ProposalDecorator::ACCEPTED,
        ProposalDecorator::WAITLISTED,
        ProposalDecorator::WITHDRAWN,
        ProposalDecorator::SUBMITTED,
        ProposalDecorator::SOFT_ACCEPTED,
        ProposalDecorator::SOFT_WAITLISTED,
        ProposalDecorator::SOFT_REJECTED
      ]

      states.each do |state|
        proposal = create(:proposal_with_track, state: state)
        expect(proposal.decorate.state).to eq(state)
      end
    end
  end
end
