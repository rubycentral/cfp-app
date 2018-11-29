require 'rails_helper'

feature "Organizers can manage proposals" do

  let(:event) { create(:event, review_tags: ['intro', 'advanced']) }
  let(:proposal) { create(:proposal, event: event) }

  let(:organizer_user) { create(:user) }
  let!(:event_staff_teammate) { create(:teammate, :organizer, user: organizer_user, event: event) }

  let(:speaker_user) { create(:user) }
  let!(:speaker) { create(:speaker, proposal: proposal, user: speaker_user) }

  let!(:tagging) { create(:tagging, proposal: proposal) }
  let!(:review_tagging) { create(:tagging, :review_tagging, proposal: proposal) }

  before :each do
    login_as(organizer_user)
    ActionMailer::Base.deliveries.clear
  end

  after { ActionMailer::Base.deliveries.clear }

  context "Proposals Page" do
    before { visit event_staff_program_proposals_path(event) }

    context "Soft accepting a proposal" do
      it "sets proposal state and does not notify the speaker" do
        updated_by_speaker_at = proposal.updated_by_speaker_at
        click_link 'Accept'

        expect(proposal.reload.state).to eql(Proposal::State::SOFT_ACCEPTED)
        expect(ActionMailer::Base.deliveries).to be_empty
        expect(proposal.reload.updated_by_speaker_at).to eql(updated_by_speaker_at)
      end
    end

    context "Soft rejecting a proposal" do
      it "sets proposal state and does not notify the speaker" do
        updated_by_speaker_at = proposal.updated_by_speaker_at
        click_link 'Reject'

        expect(proposal.reload.state).to eql(Proposal::State::SOFT_REJECTED)
        expect(ActionMailer::Base.deliveries).to be_empty
        expect(proposal.reload.updated_by_speaker_at).to eql(updated_by_speaker_at)
      end
    end

    context "Soft waitlisting a proposal" do
      it "sets proposal state and does not notify the speaker" do
        updated_by_speaker_at = proposal.updated_by_speaker_at
        click_link 'Waitlist'

        expect(proposal.reload.state).to eql(Proposal::State::SOFT_WAITLISTED)
        expect(ActionMailer::Base.deliveries).to be_empty
        expect(proposal.reload.updated_by_speaker_at).to eql(updated_by_speaker_at)
      end
    end
  end

  xcontext "Edit a proposal" do
    before do
      proposal.last_change = ['abstract']
      proposal.save!
      visit edit_event_staff_proposal_path(event, proposal)
      fill_in "Title", with: "A New Title"
      click_button 'Save'
      proposal.reload
    end

    it "changes the title of the proposal" do
      expect(proposal.title).to eq("A New Title")
    end

    it "clears out the last_change array" do

      expect(proposal.last_change).to be_nil
    end
  end

  context "Viewing a proposal" do
    it_behaves_like "a proposal page", :event_staff_proposal_path

    before do
      visit event_staff_program_proposal_path(event, proposal)
    end

    it "links back button to the proposals page" do
      back = find("a", :text => "« Return to Proposals")
      expect(back[:href]).to eq(event_staff_program_proposals_path(event))
    end

    context "Accepting a proposal" do
      before do
        click_link 'Accept'
        visit event_staff_program_proposal_path(event, proposal)
        click_link 'Finalize State'
      end

      it "sets proposal state to accepted" do
        expect(proposal.reload.state).to eql(Proposal::State::ACCEPTED)
      end

      it "sends an email notification to the speaker" do
        expect(ActionMailer::Base.deliveries.last.to).to include(speaker_user.email)
      end
    end

    context "Rejecting a proposal" do
      before do
        click_link 'Reject'
        visit event_staff_program_proposal_path(event, proposal)
        click_link 'Finalize State'
      end

      it "sets proposal state to rejected" do
        expect(proposal.reload.state).to eql(Proposal::State::REJECTED)
      end

      it "sends an email notification to the speaker" do
        expect(ActionMailer::Base.deliveries.last.to).to include(speaker_user.email)
      end
    end

    context "Waitlisting a proposal" do
      before do
        click_link 'Waitlist'
        visit event_staff_program_proposal_path(event, proposal)
        click_link 'Finalize State'
      end

      it "sets proposal state to waitlisted" do
        expect(proposal.reload.state).to eql(Proposal::State::WAITLISTED)
      end

      it "sends an email notification to the speaker" do
        expect(ActionMailer::Base.deliveries.last.to).to include(speaker_user.email)
      end

      it "creates a draft program session" do
        expect(proposal.program_session.state).to eq(ProgramSession::UNCONFIRMED_WAITLISTED)
      end
    end

    context "Promoting a waitlisted proposal" do
      let(:proposal) { create(:proposal, state: Proposal::State::WAITLISTED) }
      let(:program_session) { create(:program_session, state: ProgramSession::UNCONFIRMED_WAITLISTED, proposal: proposal) }

      before do
        visit event_staff_program_session_path(event, program_session)
        click_link 'Promote'
      end

      it "sets proposal state to accepted and program session state to unconfirmed_accepted" do
        expect(proposal.reload.state).to eql(Proposal::State::ACCEPTED)
        expect(program_session.reload.state).to eql(ProgramSession::UNCONFIRMED_ACCEPTED)
      end

      it "doesn't send an email notification" do
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end
  end
end
