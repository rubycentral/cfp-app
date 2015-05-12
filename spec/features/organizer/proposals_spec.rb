require 'rails_helper'

feature "Organizers can manage proposals" do

  let(:event) { create(:event, review_tags: ['intro', 'advanced']) }
  let(:proposal) { create(:proposal, event: event) }

  let(:organizer_person) { create(:person) }
  let!(:organizer_participant) { create(:participant, :organizer, person: organizer_person, event: event) }

  let(:speaker_person) { create(:person) }
  let!(:speaker) { create(:speaker, proposal: proposal, person: speaker_person) }

  before :each do
    login_user(organizer_person)
  end

  after { ActionMailer::Base.deliveries.clear }

  context "Proposals Page" do
    before { visit organizer_event_proposals_path(event) }

    context "Soft accepting a proposal" do
      before { click_link 'Accept' }

      it "sets proposal state to soft accepted" do
        expect(proposal.reload.state).to eql(Proposal::State::SOFT_ACCEPTED)
      end

      it "does not send an email notification to the speaker" do
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end

    context "Soft rejecting a proposal" do
      before { click_link 'Reject' }

      it "sets proposal state to soft rejected" do
        expect(proposal.reload.state).to eql(Proposal::State::SOFT_REJECTED)
      end

      it "sends an email notification to the speaker" do
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end

    context "Soft waitlisting a proposal" do
      before { click_link 'Waitlist' }

      it "sets proposal state to soft waitlisted" do
        expect(proposal.reload.state).to eql(Proposal::State::SOFT_WAITLISTED)
      end

      it "sends an email notification to the speaker" do
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end
  end

  context "Edit a proposal" do
    before do
      proposal.last_change = ['abstract']
      proposal.save!
      visit edit_organizer_event_proposal_path(event, proposal)
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
    it_behaves_like "a proposal page", :organizer_event_proposal_path

    before do
      visit organizer_event_proposal_path(event, proposal)
    end

    it "links back button to the proposals page" do
      back = find('#back')
      expect(back[:href]).to eq(organizer_event_proposals_path(event))
    end

    context "Accepting a proposal" do
      before do
        click_link 'Accept'
        visit organizer_event_proposal_path(event, proposal)
        click_link 'Finalize State'
      end

      it "sets proposal state to accepted" do
        expect(proposal.reload.state).to eql(Proposal::State::ACCEPTED)
      end

      it "sends an email notification to the speaker" do
        expect(ActionMailer::Base.deliveries.last.bcc).to include(speaker_person.email)
      end
    end

    context "Rejecting a proposal" do
      before do
        click_link 'Reject'
        visit organizer_event_proposal_path(event, proposal)
        click_link 'Finalize State'
      end

      it "sets proposal state to rejected" do
        expect(proposal.reload.state).to eql(Proposal::State::REJECTED)
      end

      it "sends an email notification to the speaker" do
        expect(ActionMailer::Base.deliveries.last.bcc).to include(speaker_person.email)
      end
    end

    context "Waitlisting a proposal" do
      before do
        click_link 'Waitlist'
        visit organizer_event_proposal_path(event, proposal)
        click_link 'Finalize State'
      end

      it "sets proposal state to waitlisted" do
        expect(proposal.reload.state).to eql(Proposal::State::WAITLISTED)
      end

      it "sends an email notification to the speaker" do
        expect(ActionMailer::Base.deliveries.last.bcc).to include(speaker_person.email)
      end
    end

    context "Promoting a waitlisted proposal" do
      let(:proposal) { create(:proposal, state: Proposal::State::WAITLISTED) }

      before do
        visit organizer_event_proposal_path(event, proposal)
        click_link 'Promote'
      end

      it "sets proposal state to waitlisted" do
        expect(proposal.reload.state).to eql(Proposal::State::ACCEPTED)
      end

      it "doesn't send an email notification" do
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end

    context "Declining a waitlisted proposal" do
      let(:proposal) { create(:proposal, state: Proposal::State::WAITLISTED) }

      before do
        visit organizer_event_proposal_path(event, proposal)
        click_link 'Decline'
      end

      it "sets proposal state to waitlisted" do
        expect(proposal.reload.state).to eql(Proposal::State::REJECTED)
      end

      it "doesn't send an email notification" do
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end
  end

  context "update_without_touching_updated_by_speaker_at" do
    it "doesn't update the update_by_speaker_at column" do
      tag = create(:tagging)
      updated_at = 1.day.ago
      proposal.update_column(:updated_by_speaker_at, updated_at)
      proposal.update_without_touching_updated_by_speaker_at(review_tags: [tag.tag])
      proposal.reload
      expect(proposal.updated_by_speaker_at.to_s).to eq(updated_at.to_s)
    end
  end
end
