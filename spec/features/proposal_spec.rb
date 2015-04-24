require 'rails_helper'

feature "Proposals" do
  let(:user) { create(:person) }
  let(:event) { create(:event, state: 'open') }
  let(:go_to_new_proposal) { visit new_proposal_path(slug: event.slug) }
  let(:create_proposal) do
    fill_in 'Title', with: "General Principles Derived by Magic from My Personal Experience"
    fill_in 'Abstract', with: "Because certain things happened to me, they will happen in just the same manner to everyone."
    fill_in 'proposal_speakers_attributes_0_bio', with: "I am awesome."
    fill_in 'Pitch', with: "You live but once; you might as well be amusing. - Coco Chanel"
    fill_in 'Details', with: "Plans are nothing; planning is everything. - Dwight D. Eisenhower"
    click_button 'Submit Proposal'
  end

  before { login_user(user) }
  after { ActionMailer::Base.deliveries.clear }

  context "when submitting" do
    context "with an existing bio" do
      before { user.update_attribute(:bio, 'bio') }

      it "shows the user's bio in the bio field" do
        go_to_new_proposal
        expect(page).to have_field('Bio', with: 'bio')
      end
    end

    context "With Pitch and Details" do
      before :each do
        go_to_new_proposal
        create_proposal
      end

      it "submits succesfully" do
        expect(page).to have_text("Thank you for submitting")
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

      proposal = user.proposals.first

      visit edit_proposal_path(slug: proposal.event.slug, uuid: proposal)
      fill_in 'Title', with: "A new title"
      click_button 'Submit Proposal'
      expect(page).to have_text("A new title")
    end
  end

  context "when commenting" do
    before :each do
      go_to_new_proposal
      create_proposal
      proposal = user.proposals.first
      visit proposal_path(slug: proposal.event.slug, uuid: proposal)
      fill_in 'public_comment_body', with: "Here's a comment for you!"
      click_button 'Comment'
    end

    scenario "User comments on their proposal" do
      expect(page).to have_text("Here's a comment for you!")
    end

    it "does not show the speaker's name" do
      within(:css, 'div.speaker-comment') do
        expect(page).not_to have_text(user.name)
      end
    end
  end

  context "when confirming" do
    let(:proposal) { create(:proposal) }

    before { proposal.update(state: Proposal::State::ACCEPTED) }

    context "when the proposal has not yet been confirmed" do
      let!(:speaker) { create(:speaker, proposal: proposal, person: user) }

      before do
        visit confirm_proposal_path(slug: proposal.event.slug, uuid: proposal)
          click_button "Confirm"
      end

      it "marks the proposal as confirmed" do
        expect(proposal.reload.confirmed?).to be_truthy
      end

      it "redirects the user to the proposal page" do
        expect(page).to have_text(proposal.title)
      end
    end

    context "when the proposal has already been confirmed" do
      let!(:speaker) { create(:speaker, proposal: proposal, person: user) }

      before do
        proposal.update(confirmed_at: DateTime.now)
        visit confirm_proposal_path(slug: proposal.event.slug, uuid: proposal)
      end

      it "does not show the confirmation link" do
        expect(page).not_to have_link('Confirm my participation')
      end

      it "says when the proposal was confirmed" do
        expect(page).to have_text("This proposal was confirmed on")
      end
    end

    context "with a speaker who isn't on the proposal" do
      it "allows the user to access the confirmation page" do
        path = confirm_proposal_path(slug: proposal.event.slug, uuid: proposal)
        visit path
        expect(current_path).to eq(path)
      end
    end
  end

  context "when deleted" do
    let(:proposal) { create(:proposal, event: event, state: Proposal::State::SUBMITTED) }
    let!(:speaker) { create(:speaker, proposal: proposal, person: user) }

    before do
      visit proposal_path(slug: event.slug, uuid: proposal)
      click_link 'delete'
    end

    it "redirects to the proposal show page" do
      expect(page).not_to have_text(proposal.title)
    end
  end

  context "when withdrawn" do
    let(:proposal) { create(:proposal, :with_reviewer_public_comment, event: event, state: Proposal::State::SUBMITTED) }
    let!(:speaker) { create(:speaker, proposal: proposal, person: user) }

    before do
      visit proposal_path(slug: event.slug, uuid: proposal)
      click_link 'Withdraw'
      expect(page).to have_content("Your withdrawal request has been submitted.")
    end

    it "sends a notification to reviewers" do
      expect(Notification.count).to eq(1)
    end

    it "redirects to the proposal show page" do
      expect(page).to have_text(proposal.title)
    end
  end
end
