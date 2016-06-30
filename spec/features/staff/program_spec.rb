require 'rails_helper'

feature "Organizers can manage the program" do

  let(:proposal) { create(:proposal, state: Proposal::State::ACCEPTED) }
  let(:organizer) { create(:organizer, event: proposal.event) }

  before { login_as(organizer) }

  context "Viewing the program" do
    it "can view the program" do
      visit event_staff_program_path(proposal.event)
      expect(page).to have_text("#{proposal.event.name} Program")
      expect(page).to have_text(proposal.title)
    end
  end

  context "Viewing a proposal" do
    it "links back button to the program page" do
      visit event_staff_program_path(proposal.event)
      visit event_staff_proposal_path(proposal.event, proposal)
      back = find('#back')
      expect(back[:href]).to eq(event_staff_program_path(proposal.event))
    end
  end

  context "Organizers can see confirmation feedback clearly" do
    it "shows speakers confirmation feedback" do
      visit event_staff_program_path(proposal.event)
      expect(page).to have_text("Notes")
    end
  end
end
