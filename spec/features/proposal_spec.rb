require 'rails_helper'

feature "Proposals" do
  let!(:user) { create(:user) }
  let!(:event) { create(:event, state: 'open') }
  let!(:closed_event) { create(:event, state: 'closed') }
  let!(:session_format) { create(:session_format, name: 'Only format')}
  let(:session_format2) { create(:session_format, name: '2nd format')}

  let(:go_to_new_proposal) { visit new_event_proposal_path(event_slug: event.slug) }

  let(:create_proposal) do
    fill_in 'Title', with: "General Principles Derived by Magic from My Personal Experience"
    fill_in 'Abstract', with: "Because certain things happened to me, they will happen in just the same manner to everyone."
    fill_in 'proposal_speakers_attributes_0_bio', with: "I am awesome."
    fill_in 'Pitch', with: "You live but once; you might as well be amusing. - Coco Chanel"
    fill_in 'Details', with: "Plans are nothing; planning is everything. - Dwight D. Eisenhower"
    select 'Only format', from: 'Session format'
    click_button 'Submit'
  end

  let(:create_invalid_proposal) do
    fill_in 'proposal_speakers_attributes_0_bio', with: "I am a great speaker!."
    fill_in 'Pitch', with: "You live but once; you might as well be amusing. - Coco Chanel"
    fill_in 'Details', with: "Plans are nothing; planning is everything. - Dwight D. Eisenhower"
    click_button 'Submit'
  end

  before { login_as(user) }
  after { ActionMailer::Base.deliveries.clear }

  context "when navigating to new proposal page" do
    context "after closing time" do
      it "redirects and displays flash" do
        visit new_event_proposal_path(event_slug: closed_event.slug)

        expect(current_path).to eq event_path(closed_event)
        expect(page).to have_text("The CFP is closed for proposal submissions.")
      end
    end
  end

  context "when submitting", js: true do
    context "with invalid proposal" do
      before :each do
        go_to_new_proposal
        create_invalid_proposal
      end

      it "submits unsuccessfully" do
        expect(page).to have_text("There was a problem saving your proposal.")
      end

      it "shows Title validation if blank on submit" do
        expect(page).to have_text("Title * can't be blank")
      end

      it "shows Abstract validation if blank on submit" do
        expect(page).to have_text("Abstract * can't be blank")
      end
    end

    context "less than one hour after CFP closes" do
      before :each do
        go_to_new_proposal
        event.update(state: 'closed')
        event.update(closes_at: 55.minutes.ago)
        create_proposal
      end

      it "submits successfully" do
        expect(page).to have_text("Your proposal has been submitted and may be reviewed at any time while the CFP is open.")
      end
    end

    context "more than one hour after CFP closes" do
      before :each do
        go_to_new_proposal
        event.update(state: 'closed')
        event.update(closes_at: 65.minutes.ago)
        create_proposal
      end

      it "does not submit" do
        expect(page).to have_text("The CFP is closed for proposal submissions.")
      end
    end

    context "with Session Formats" do
      #Default if one Session Format that it is auto-selected
      it "doesn't show session format validation if one session format" do
        go_to_new_proposal
        create_invalid_proposal
        expect(page).to_not have_text("Session format *None selected Only format 2nd formatcan't be blank")
      end

      it "shows Session Format validation if two session formats" do
        skip "Address after session format change"
        session_format2.save!
        go_to_new_proposal
        create_invalid_proposal
        expect(page).to have_text("Session format *None selected Only format 2nd formatcan't be blank")
      end
    end

    context "with an existing bio" do
      before { user.update_attribute(:name, 'new speaker') }
      before { user.update_attribute(:bio, 'new bio') }

      it "shows the user's bio in the bio field" do
        go_to_new_proposal
        expect(page).to have_field('Bio', with: 'new bio')
      end

      it "shows the user's name in the name field" do
        go_to_new_proposal
        expect(page).to have_field('Name', disabled: true, with: 'new speaker')
      end
    end

    context "With Pitch and Details" do
      before :each do
        go_to_new_proposal
        create_proposal
      end

      it "submits successfully" do
        expect(Proposal.last.abstract).to_not match('<p>')
        expect(Proposal.last.abstract).to_not match('</p>')
        expect(page).to have_text("Your proposal has been submitted and may be reviewed at any time while the CFP is open.")
      end

      it "does not create an empty comment" do
        expect(Proposal.last.public_comments).to be_empty
      end

      it "shows the proposal on the user's proposals list" do
        visit proposals_path
        within(:css, 'div.proposals') do
          expect(page).to have_text("General Principles")
        end
      end
    end
  end

  context "when editing" do
    scenario "User edits their proposal" do
      go_to_new_proposal
      create_proposal
      click_link 'Edit'

      expect(page).to_not have_text("A new title")
      fill_in 'Title', with: "A new title"
      click_button 'Submit'
      expect(page).to have_text("A new title")
    end
  end

  context "when commenting" do
    before :each do
      go_to_new_proposal
      create_proposal
      fill_in 'public_comment_body', with: "Here's a comment for you!"
      click_button 'Comment'
    end

    scenario "User comments on their proposal" do
      expect(page).to have_text("Here's a comment for you!")
    end

    it "it does not show the speaker's name" do
      within(:css, '.speaker-comment') do
        expect(page).to have_text("speaker")
      end
    end
  end

  context "when confirming" do
    let(:proposal) { create(:proposal) }

    before do
      proposal.update(state: Proposal::State::ACCEPTED)
      ProgramSession.create_from_proposal(proposal)
    end

    context "when the proposal has not yet been confirmed" do
      let!(:speaker) { create(:speaker, proposal: proposal, user: user) }

      before do
        visit event_proposal_path(event_slug: proposal.event.slug, uuid: proposal)
        click_link "Confirm"
      end

      it "marks the proposal as confirmed" do
        expect(proposal.reload.confirmed?).to be_truthy
      end

      it "redirects the user to the proposal page" do
        expect(current_path).to eq(event_proposal_path(event_slug: proposal.event.slug, uuid: proposal))
        expect(page).to have_text(proposal.title)
        expect(page).to have_text("You have confirmed your participation in #{proposal.event.name}.")
      end
    end

    context "when the proposal has already been confirmed" do
      let!(:speaker) { create(:speaker, proposal: proposal, user: user) }

      before do
        proposal.update(confirmed_at: DateTime.now)
        visit event_proposal_path(event_slug: proposal.event.slug, uuid: proposal)
      end

      it "does not show the confirmation link" do
        expect(page).not_to have_link('Confirm my participation')
      end
    end

  end

  context "when deleted" do
    let(:proposal) { create(:proposal, event: event, state: Proposal::State::SUBMITTED) }
    let!(:speaker) { create(:speaker, proposal: proposal, user: user) }

    before do
      visit event_proposal_path(event_slug: event.slug, uuid: proposal)
      click_link 'delete'
    end

    it "redirects to the proposal show page" do
      expect(page).not_to have_text(proposal.title)
    end
  end

  context "when withdrawn" do
    let(:proposal) { create(:proposal, :with_reviewer_public_comment, event: event, state: Proposal::State::SUBMITTED) }
    let!(:speaker) { create(:speaker, proposal: proposal, user: user) }

    before do
      visit event_proposal_path(event_slug: event.slug, uuid: proposal)
      click_link 'Withdraw'
      expect(page).to have_content("As requested, your talk has been removed for consideration.")
    end

    it "sends a notification to reviewers" do
      expect(Notification.count).to eq(1)
    end

    it "redirects to the proposal show page" do
      expect(page).to have_text(proposal.title)
    end
  end

  context "when declined" do

    before do
      @proposal = create(:proposal, state: Proposal::State::ACCEPTED)
      speaker = create(:speaker, proposal: @proposal, user: user)
      @proposal.speakers << speaker
      ProgramSession.create_from_proposal(@proposal)
      visit event_proposal_path(event_slug: @proposal.event.slug, uuid: @proposal)
      click_link "Decline"
    end

    it "marks the proposal as withdrawn" do
      expect(@proposal.reload.withdrawn?).to be_truthy
    end

    it "marks the proposal as confirmed" do
      expect(@proposal.reload.confirmed?).to be_truthy
    end

    it "redirects the user to the proposal page" do
      expect(current_path).to eq(event_proposal_path(event_slug: @proposal.event.slug, uuid: @proposal))
      expect(page).to have_text(@proposal.title)
      expect(page).to have_text("As requested, your talk has been removed for consideration.")
    end
  end
end
