require 'rails_helper'

feature "Review Proposals" do
  let(:event) { create(:event, state: 'open') }
  let(:reviewer_person) {create(:person) }

  # First proposal
  let(:user) { create(:person) }
  let(:proposal) { create(:proposal,
                          title: 'First Proposal',
                          abstract: 'Well then.',
                          event: event)
  }
  let!(:speaker) { create(:speaker,
                         person: user,
                         proposal: proposal)
  }

  # Another proposal
  let(:user2) { create(:person) }
  let(:proposal2) { create(:proposal,
                          title: 'Second Proposal',
                          abstract: 'This is second.',
                          event: event)
  }
  let!(:speaker2) { create(:speaker,
                         person: user2,
                         proposal: proposal2)
  }

  # Reviewer
  let!(:reviewer_participant) { create(:participant, :reviewer, person: reviewer_person, event: event) }

  before { login_user(reviewer_person) }

  context "When viewing proposal list" do
    it "shows the proposal list" do
      visit reviewer_event_proposals_path(event)
      expect(page).to have_text("First Proposal")
      expect(page).to have_text("Second Proposal")
    end

    it "only shows the average rating if you've rated it" do
      # logged-in user rates `proposal` as a 4
      reviewer_person.ratings.create(proposal: proposal, score: 4)

      # someone else has rated `proposal2` as a 4
      other_reviewer = create(:participant, :reviewer, event: event).person
      other_reviewer.ratings.create(proposal: proposal2, score: 4)

      visit reviewer_event_proposals_path(event)

      within(".proposal-#{proposal.id}") do
        expect(page).to have_content("4.0")
      end

      within(".proposal-#{proposal2.id}") do
        expect(page).to_not have_content("4.0")
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
                                     person: reviewer_person,
                                     proposal: reviewer_proposal)
    }

    scenario "they can't view their own proposals" do
      visit reviewer_event_proposals_path(event)
      expect(page).not_to have_text("Reviewer Proposal")
    end

    scenario "they can't rate their own proposals" do
      visit reviewer_event_proposal_path(event, reviewer_proposal)
      expect(page).not_to have_select('rating_score')
    end
  end

  context "reviewer is viewing a specific proposal" do
    it_behaves_like "a proposal page", :reviewer_event_proposal_path

    it "only shows them the internal comments once they've rated it", js: true do
      visit reviewer_event_proposal_path(event, proposal)
      expect(page).to_not have_content('Internal Comments')

      select('3', from: 'Rating')

      expect(page).to have_content('Internal Comments')
    end
  end
end
