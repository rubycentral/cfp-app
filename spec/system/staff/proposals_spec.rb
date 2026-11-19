require 'rails_helper'

feature "Organizers can manage proposals", type: :system do
  let(:event) { create(:event, review_tags: ['intro', 'advanced']) }
  let(:proposal) { create(:proposal_with_track, event: event) }

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

        expect(proposal.reload).to be_soft_accepted
        expect(ActionMailer::Base.deliveries).to be_empty
        expect(proposal.reload.updated_by_speaker_at).to be_within(1.second).of(updated_by_speaker_at)
      end
    end

    context "Soft rejecting a proposal" do
      it "sets proposal state and does not notify the speaker" do
        updated_by_speaker_at = proposal.updated_by_speaker_at
        click_link 'Reject'

        expect(proposal.reload).to be_soft_rejected
        expect(ActionMailer::Base.deliveries).to be_empty
        expect(proposal.reload.updated_by_speaker_at).to be_within(1.second).of(updated_by_speaker_at)
      end
    end

    context "Soft waitlisting a proposal" do
      it "sets proposal state and does not notify the speaker" do
        updated_by_speaker_at = proposal.updated_by_speaker_at
        click_link 'Waitlist'

        expect(proposal.reload).to be_soft_waitlisted
        expect(ActionMailer::Base.deliveries).to be_empty
        expect(proposal.reload.updated_by_speaker_at).to be_within(1.second).of(updated_by_speaker_at)
      end
    end
  end

  context "tracks" do
    context "when the event has no tracks" do
      let(:proposal) { create(:proposal, event: event) }

      it "shows no track column or field on the program proposal pages" do
        visit event_staff_program_proposals_path(event)
        expect(page).to have_css('th', text: 'Speakers')
        expect(page).not_to have_css('th', text: 'Track')

        visit selection_event_staff_program_proposals_path(event)
        expect(page).to have_css('th', text: 'Speakers')
        expect(page).not_to have_css('th', text: 'Track')

        visit event_staff_program_proposal_path(event, proposal)
        expect(page).to have_content('Format')
        expect(page).not_to have_content('Track')
      end
    end

    context "when the event has a track" do
      it "shows the track column and field on the program proposal pages" do
        visit event_staff_program_proposals_path(event)
        expect(page).to have_css('th', text: 'Track')

        visit selection_event_staff_program_proposals_path(event)
        expect(page).to have_css('th', text: 'Track')

        visit event_staff_program_proposal_path(event, proposal)
        expect(page).to have_content('Track')
      end
    end
  end

  context "Viewing a proposal" do
    it_behaves_like "a proposal page", :event_staff_proposal_path

    before do
      visit event_staff_program_proposal_path(event, proposal)
    end

    it "marks the organizer's notifications about the proposal as read" do
      # Notifications are matched to the page by full URL, so build it for the host Capybara browses
      Notification.create_for(organizer_user, proposal: proposal, message: 'A fancy notification',
                              target_path: Capybara.default_host + event_staff_proposal_path(event, proposal))
      visit event_staff_proposal_path(event, proposal)
      expect(organizer_user.notifications.unread).to be_empty
    end

    context "editing the format and track inline", js: true do
      let!(:workshop) { create(:session_format, event: event, name: 'Workshop') }
      let!(:hardware) { create(:track, event: event, name: 'Hardware') }

      it "changes the session format" do
        visit event_staff_program_proposal_path(event, proposal)
        within('#current-format') { find('.inline-edit-icon').click }
        select 'Workshop', from: 'proposal_session_format_id'
        within('#format-name') { expect(page).to have_text('Workshop') }
        expect(proposal.reload.session_format).to eq(workshop)
      end

      it "changes the track" do
        visit event_staff_program_proposal_path(event, proposal)
        within('#current-track') { find('.inline-edit-icon').click }
        select 'Hardware', from: 'proposal_track_id'
        within('#track-name') { expect(page).to have_text('Hardware') }
        expect(proposal.reload.track).to eq(hardware)
      end
    end

    it "links each speaker to their program speaker page from the info bar" do
      within(".proposal-info-bar.clearfix") do
        expect(page).to have_link(speaker_user.name, href: event_staff_program_speaker_path(event, speaker))
      end
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
        expect(proposal.reload).to be_accepted
      end

      it "creates a draft program session" do
        expect(proposal.reload.program_session).to be_unconfirmed_accepted
      end

      it "sends an email notification to the speaker" do
        expect(ActionMailer::Base.deliveries.last.to).to include(speaker_user.email)
      end

      it "notifies the speaker in the app" do
        expect(speaker_user.notifications.count).to eq(1)
      end
    end

    context "Rejecting a proposal" do
      before do
        click_link 'Reject'
        visit event_staff_program_proposal_path(event, proposal)
        click_link 'Finalize State'
      end

      it "sets proposal state to rejected" do
        expect(proposal.reload).to be_rejected
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
        expect(proposal.reload).to be_waitlisted
      end

      it "sends an email notification to the speaker" do
        expect(ActionMailer::Base.deliveries.last.to).to include(speaker_user.email)
      end

      it "creates a draft program session" do
        expect(proposal.program_session).to be_unconfirmed_waitlisted
      end
    end
  end
end
