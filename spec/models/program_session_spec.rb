require 'rails_helper'

describe ProgramSession do

  let(:proposal) { create(:proposal_with_track, :with_two_speakers) }

  let(:waitlisted_proposal) { create(:proposal_with_track, :with_two_speakers, state: 'waitlisted') }

  it "responds to .create_from_proposal" do
    expect(ProgramSession).to respond_to(:create_from_proposal)
  end

  describe "#create_from_proposal" do

    it "creates a new program session with the same title as the given proposal" do
      session = ProgramSession.create_from_proposal(proposal)

      expect(session.title).to eq(proposal.title)
    end

    it "creates a new program session with the same abstract as the given proposal" do
      session = ProgramSession.create_from_proposal(proposal)

      expect(session.abstract).to eq(proposal.abstract)
    end

    it "creates a new program session with the same event as the given proposal" do
      session = ProgramSession.create_from_proposal(proposal)

      expect(session.event_id).to eq(proposal.event_id)
    end

    it "creates a new program session with the same session format as the given proposal" do
      session = ProgramSession.create_from_proposal(proposal)

      expect(session.session_format_id).to eq(proposal.session_format_id)
    end

    it "creates a new program session with the same track as the given proposal" do
      session = ProgramSession.create_from_proposal(proposal)

      expect(session.track_id).to eq(proposal.track_id)
    end

    it "creates a program session that has the proposal id" do
      session = ProgramSession.create_from_proposal(proposal)

      expect(session.proposal_id).to eq(proposal.id)
    end

    it "creates a program session that is a draft" do
      session = ProgramSession.create_from_proposal(proposal)

      expect(session.state).to eq("unconfirmed accepted")
    end

    it "creates a program session that is waitlisted" do
      session = ProgramSession.create_from_proposal(waitlisted_proposal)

      expect(session.state).to eq("unconfirmed waitlisted")
    end

    it "sets program session id for all speakers" do
      session = ProgramSession.create_from_proposal(proposal)

      expect(session.speakers).to match_array(proposal.speakers)
    end

    it "sets speaker_name from user on each speaker" do
      proposal.speakers.each do |speaker|
        expect(speaker.speaker_name).to eq(nil)
      end

      session = ProgramSession.create_from_proposal(proposal)

      session.speakers.each do |speaker|
        expect(speaker.speaker_name).to eq(speaker.user.name)
        expect(speaker.changed?).to be(false)
      end
    end

    it "sets speaker_email from user on each speaker" do
      proposal.speakers.each do |speaker|
        expect(speaker.speaker_email).to eq(nil)
      end

      session = ProgramSession.create_from_proposal(proposal)

      session.speakers.each do |speaker|
        expect(speaker.speaker_email).to eq(speaker.user.email)
        expect(speaker.changed?).to be(false)
      end
    end

    it "sets bio from user on each speaker" do
      proposal.speakers.each do |speaker|
        expect(speaker.bio).to eq(nil)
      end

      session = ProgramSession.create_from_proposal(proposal)

      session.speakers.each do |speaker|
        expect(speaker.bio.present?).to eq(true)
        expect(speaker.bio).to eq(speaker.user.bio)
        expect(speaker.changed?).to be(false)
      end
    end

    it "does not overwrite speaker_name if it already has a value" do
      my_proposal = create(:proposal)
      user = create(:user, name: "Fluffy", email: "fluffy@email.com")
      create(:speaker,
              user_id: user.id,
              event_id: my_proposal.event_id,
              proposal_id: my_proposal.id,
              speaker_name: "Unicorn")

      ProgramSession.create_from_proposal(my_proposal)
      ps_speaker = my_proposal.speakers.first

      expect(ps_speaker.speaker_name).to eq("Unicorn")
      expect(ps_speaker.speaker_email).to eq("fluffy@email.com")
      expect(ps_speaker.changed?).to be(false)
    end

    it "does not overwrite speaker_email if it already has a value" do
      my_proposal = create(:proposal)
      user = create(:user, name: "Fluffy", email: "fluffy@email.com" )
      create(:speaker,
             user_id: user.id,
             event_id: my_proposal.event_id,
             proposal_id: my_proposal.id,
             speaker_email: "unicorn@email.com")

      ProgramSession.create_from_proposal(my_proposal)
      ps_speaker = my_proposal.speakers.first

      expect(ps_speaker.speaker_name).to eq("Fluffy")
      expect(ps_speaker.speaker_email).to eq("unicorn@email.com")
      expect(ps_speaker.changed?).to be(false) #returns true if there are unsaved changes
    end

    it "does not overwrite bio if it already has a value" do
      my_proposal = create(:proposal)
      user = create(:user, name: "Fluffy", email: "fluffy@email.com", bio: "Fluffy rules all day." )
      create(:speaker,
             user_id: user.id,
             event_id: my_proposal.event_id,
             proposal_id: my_proposal.id,
             bio: "Went to Unicorniversity of Ohio.")

      ProgramSession.create_from_proposal(my_proposal)
      ps_speaker = my_proposal.speakers.first

      expect(ps_speaker.speaker_name).to eq("Fluffy")
      expect(ps_speaker.speaker_email).to eq("fluffy@email.com")
      expect(ps_speaker.bio).to eq("Went to Unicorniversity of Ohio.")
      expect(ps_speaker.changed?).to be(false) #returns true if there are unsaved changes
    end

    it "retains proposal id on each speaker" do
      ProgramSession.create_from_proposal(proposal)

      proposal.speakers.each do |speaker|
        expect(speaker.proposal_id).to eq(proposal.id)
        expect(speaker.changed?).to be(false)
      end
    end

  end

  describe "#can_promote?" do
    it "returns true for promotable states" do
      draft = create(:program_session, state: "draft")
      unconfirmed_waitlisted = create(:program_session, state: "unconfirmed waitlisted")
      confirmed_waitlisted = create(:program_session, state: "confirmed waitlisted")

      [draft, unconfirmed_waitlisted, confirmed_waitlisted].each do |ps|
        expect(ps.can_promote?).to be(true)
      end
    end

    it "returns false for non-promotable states" do
      live = create(:program_session, state: "live")
      unconfirmed_accepted = create(:program_session, state: "unconfirmed accepted")
      declined = create(:program_session, state: "declined")

      [live, unconfirmed_accepted, declined].each do |ps|
        expect(ps.can_promote?).to be(false)
      end
    end
  end

  describe "#promote" do
    it "promotes a draft to accepted_confirmed" do
      ps = create(:program_session, state: "draft")
      ps.promote

      expect(ps.reload.state).to eq("live")
    end

    it "promotes an unconfirmed waitlisted to unconfirmed_accepted" do
      ps = create(:program_session, state: "unconfirmed waitlisted")
      ps.promote

      expect(ps.reload.state).to eq("unconfirmed accepted")
    end

    it "promotes a confirmed_waitlisted to live" do
      ps = create(:program_session, state: "confirmed waitlisted")
      ps.promote

      expect(ps.reload.state).to eq("live")
    end

    it "promotes it's proposal" do
      ps = create(:program_session)
      proposal = create(:proposal, program_session: ps)

      expect(proposal).to receive(:promote)
      ps.promote
    end
  end

  describe "#can_confirm?" do
    it "returns true for confirmable states" do
      unconfirmed_waitlisted = create(:program_session, state: "unconfirmed waitlisted")
      unconfirmed_accepted = create(:program_session, state: "unconfirmed accepted")

      [unconfirmed_waitlisted, unconfirmed_accepted].each do |ps|
        expect(ps.can_confirm?).to be(true)
      end
    end

    it "returns false for non-confirmable states" do
      live = create(:program_session, state: "live")
      draft = create(:program_session, state: "draft")
      declined = create(:program_session, state: "declined")

      [live, declined, draft].each do |ps|
        expect(ps.can_confirm?).to be(false)
      end
    end
  end

  describe "#confirm" do
    it "confirms an unconfirmed_waitlisted session" do
      ps = create(:program_session, state: "unconfirmed waitlisted")

      ps.confirm

      expect(ps.reload.state).to eq("confirmed waitlisted")
    end

    it "confirms an unconfirmed_accepted session" do
      ps = create(:program_session, state: "unconfirmed accepted")

      ps.confirm

      expect(ps.reload.state).to eq("live")
    end
  end

  describe "#destroy" do

    it "destroys speakers if speaker has no proposal_id" do
      ps = create(:program_session)
      speaker = create(:speaker, event_id: ps.event_id, program_session_id: ps.id)
      ps.destroy

      expect(Speaker.all).not_to include(speaker)
    end

    it "removes program_session_id from speaker if speaker has proposal_id" do
      proposal = create(:proposal, :with_speaker)
      ps = create(:program_session, proposal_id: proposal.id)
      ps.speakers << proposal.speakers
      ps.destroy

      expect(Speaker.all).to include(proposal.speakers.first)
      expect(proposal.speakers.first.program_session_id).to eq(nil)
    end
  end
end
