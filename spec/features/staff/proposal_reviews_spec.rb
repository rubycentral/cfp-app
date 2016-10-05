require 'rails_helper'

feature "Review Proposals" do
  let(:event) { create(:event, state: 'open') }
  let(:reviewer_user) {create(:user) }

  # First proposal
  let(:user) { create(:user) }
  let(:proposal) { create(:proposal,
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
  let(:proposal2) { create(:proposal,
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

  context "When the reviewer submits a proposal" do
    let!(:reviewer_proposal) { create(:proposal,
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
      skip "PLEASE FIX ME!"
      visit event_staff_proposal_path(event, proposal)
      expect(page).to_not have_content('Internal Comments')

      select('3', from: 'Rating')

      expect(page).to have_content('Internal Comments')
    end
  end
end
