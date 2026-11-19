require 'rails_helper'

feature "Review Proposals", type: :system do
  let(:event) { create(:event, state: 'open') }
  let(:reviewer_user) {create(:user) }

  # First proposal
  let(:user) { create(:user) }
  let(:proposal) { create(:proposal_with_track,
                          title: 'First Proposal',
                          abstract: 'Well then.',
                          event: event)
  }
  let!(:speaker) { create(:speaker,
                         user: user,
                         proposal: proposal)
  }

  # Another proposal
  let(:user2) { create(:user) }
  let(:proposal2) { create(:proposal_with_track,
                          title: 'Second Proposal',
                          abstract: 'This is second.',
                          event: event)
  }
  let!(:speaker2) { create(:speaker,
                         user: user2,
                         proposal: proposal2)
  }

  # Reviewer
  let!(:event_staff_teammate) { create(:teammate, :reviewer, user: reviewer_user, event: event) }
  let!(:tagging) { create(:tagging, proposal: proposal) }
  let!(:review_tagging) { create(:tagging, :review_tagging, proposal: proposal) }

  before { login_as(reviewer_user) }

  context "When viewing proposal list" do
    it "shows the proposal list" do
      visit event_staff_proposals_path(event)
      expect(page).to have_text("First Proposal")
      expect(page).to have_text("Second Proposal")
    end

    it "only shows the average rating if you've rated it" do
      # logged-in user rates `proposal` as a 4
      reviewer_user.ratings.create(proposal: proposal, score: 4)

      # someone else has rated `proposal2` as a 4
      user = create(:user, :reviewer)
      other_reviewer = create(:teammate, :reviewer, event: event, user: user)
      other_reviewer.user.ratings.create(proposal: proposal2, score: 4)

      visit event_staff_proposals_path(event)

      within("table .proposal-#{proposal.id}") do
        expect(page).to have_content("4.0 4")
      end

      within("table .proposal-#{proposal2.id}") do
        expect(page).to_not have_content("4.0 4")
      end
    end
  end

  context "tracks" do
    context "when the event has no tracks" do
      let(:proposal) { create(:proposal, title: 'First Proposal', event: event) }
      let(:proposal2) { create(:proposal, title: 'Second Proposal', event: event) }

      it "shows no track column or field on the review pages" do
        visit event_staff_proposals_path(event)
        expect(page).to have_css('th', text: 'Title')
        expect(page).not_to have_css('th', text: 'Track')

        visit event_staff_proposal_path(event, proposal)
        expect(page).to have_content('Format')
        expect(page).not_to have_content('Track')
      end
    end

    context "when the event has a track" do
      it "shows the track column and field on the review pages" do
        visit event_staff_proposals_path(event)
        expect(page).to have_css('th', text: 'Track')

        visit event_staff_proposal_path(event, proposal)
        expect(page).to have_content('Track')
      end
    end
  end

  context "When the reviewer submits a proposal" do
    let!(:reviewer_proposal) { create(:proposal_with_track,
                                      title: 'Reviewer Proposal',
                                      abstract: 'Yes indeed.',
                                      event: event)
    }
    let!(:reviewer_speaker) { create(:speaker,
                                     user: reviewer_user,
                                     proposal: reviewer_proposal)
    }

    scenario "they can't view their own proposals" do
      visit event_staff_proposals_path(event)
      expect(page).not_to have_text("Reviewer Proposal")
    end

    scenario "they can't rate their own proposals" do
      visit event_staff_proposal_path(event, reviewer_proposal)
      expect(page).not_to have_select('rating_score')
    end
  end

  context "reviewer is viewing a specific proposal" do
    it_behaves_like "a proposal page", :event_staff_proposal_path, js: true

    it "only shows them the internal comments once they've rated it", js: true do
      visit event_staff_proposal_path(event, proposal)
      expect(page).to_not have_content('Internal Comments')
      within("#rating-form") do
        find("input[value='5']", visible: false).set(true)
      end

      expect(page).to have_content('Internal Comments')
    end
  end

  context "when the event uses blind review" do
    before { event.update!(blind_review: true) }

    it "hides the speaker from the list and the proposal page" do
      visit event_staff_proposals_path(event)
      expect(page).not_to have_css("th", text: "Speakers")
      expect(page).not_to have_text(user.name)
      visit event_staff_proposal_path(event, proposal)
      expect(page).to have_text("Blind")
      expect(page).not_to have_text(user.name)
    end
  end

  context "when the event does not use blind review" do
    it "lists speakers and shows their names without links to the program area" do
      visit event_staff_proposals_path(event)
      within("table .proposal-#{proposal.id}") { expect(page).to have_text(user.name) }
      visit event_staff_proposal_path(event, proposal)
      expect(page).to have_text(user.name)
      expect(page).not_to have_link(user.name)
    end

    it "links speaker names for program team" do
      create(:teammate, :program_team, user: reviewer_user, event: event)
      visit event_staff_proposal_path(event, proposal)
      expect(page).to have_link(user.name, href: event_staff_program_speaker_path(event, speaker))
    end
  end
end
