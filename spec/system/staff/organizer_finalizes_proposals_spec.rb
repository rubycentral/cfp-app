require 'rails_helper'

feature "Organizers can manage proposals" do

  let(:event) { create(:event, review_tags: ['intro', 'advanced']) }
  let(:proposal) { create(:proposal_with_track, event: event) }

  let(:organizer_user) { create(:user) }
  let!(:event_staff_teammate) { create(:teammate, :organizer, user: organizer_user, event: event) }

  let(:speaker_user) { create(:user) }
  let!(:speaker) { create(:speaker, proposal: proposal, user: speaker_user) }

  before :each do
    login_as(organizer_user)
  end

  scenario "organizer can navigate to bulk finalize page from proposal selection" do
    visit selection_event_staff_program_proposals_path(event)

    expect(page).to have_content("Bulk Finalize")

    click_link("Bulk Finalize")

    expect(current_path).to eq(bulk_finalize_event_staff_program_proposals_path(event))
  end

  scenario "organizer can view soft state proposals by state" do
    proposal_two = create(:proposal_with_track, event: event)
    proposal_two.update(state: Proposal::State::SOFT_ACCEPTED)
    visit bulk_finalize_event_staff_program_proposals_path(event)

    expect(page).to have_content("1 submitted proposal")
    expect(page).to have_content("1 soft accepted proposal")
  end
end
