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

  describe "#reviewer_speaker_names" do
    let(:proposal) { create(:proposal_with_track) }
    let!(:speaker) { create(:speaker, proposal: proposal) }
    let(:decorated) { proposal.decorate }

    it "is Blind when the event uses blind review" do
      proposal.event.update!(blind_review: true)
      allow(decorated.h).to receive(:current_user).and_return(create(:user))
      expect(decorated.reviewer_speaker_names).to eq("Blind")
    end

    it "is the plain names for a reviewer" do
      allow(decorated.h).to receive(:current_user).and_return(create(:reviewer, event: proposal.event))
      expect(decorated.reviewer_speaker_names).to eq(speaker.name)
    end

    it "links the names for program team" do
      allow(decorated.h).to receive(:current_user).and_return(create(:program_team, event: proposal.event))
      html = decorated.reviewer_speaker_names
      expect(html).to include(speaker.name)
      expect(html).to include(decorated.h.event_staff_program_speaker_path(proposal.event, speaker))
    end

    it "trusts a program team check passed in instead of asking the current user" do
      allow(decorated.h).to receive(:current_user).and_return(create(:reviewer, event: proposal.event))
      expect(decorated.reviewer_speaker_names(program_team: true)).to include(decorated.h.event_staff_program_speaker_path(proposal.event, speaker))
      expect(decorated.reviewer_speaker_names(program_team: false)).to eq(speaker.name)
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
      proposal = create(:proposal_with_track, state: :rejected)
      expect(proposal.decorate.state).to eq(Proposal.states[:not_accepted])
    end

    it "returns the current state for non-rejected states" do
      states = [:accepted, :waitlisted, :withdrawn, :submitted, :soft_accepted, :soft_waitlisted, :soft_rejected]

      states.each do |state|
        proposal = create(:proposal_with_track, state: state)
        expect(proposal.decorate.state).to eq(Proposal.states[state])
      end
    end
  end
end
