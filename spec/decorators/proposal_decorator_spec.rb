require 'rails_helper'

include Proposal::State

describe ProposalDecorator do

  describe "#speaker_names" do
    it "returns speaker names as a comma separated string" do
      proposal = create(:proposal)
      speakers = create_list(:speaker, 3, proposal: proposal)
      names = proposal.decorate.speaker_names
      speakers.each do |speaker|
        expect(names).to match(speaker.name)
      end
    end
  end

  describe "#speaker_emails" do
    it "returns speaker emails as a comma separated string" do
      proposal = create(:proposal)
      speakers = create_list(:speaker, 3, proposal: proposal)
      emails = proposal.decorate.speaker_emails
      speakers.each do |speaker|
        expect(emails).to match(speaker.email)
      end
    end
  end

  describe "#state" do
    it "returns 'not accepted' for a rejected state" do
      proposal = create(:proposal, state: REJECTED)
      expect(proposal.decorate.state).to eq(NOT_ACCEPTED)
    end

    it "returns the current state for non-rejected states" do
      states = [
        ACCEPTED,
        WAITLISTED,
        WITHDRAWN,
        SUBMITTED,
        SOFT_ACCEPTED,
        SOFT_WAITLISTED,
        SOFT_REJECTED
      ]

      states.each do |state|
        proposal = create(:proposal, state: state)
        expect(proposal.decorate.state).to eq(state)
      end
    end
  end
end
