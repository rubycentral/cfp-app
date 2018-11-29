require 'rails_helper'

feature "Organizers can manage the program" do

  let(:proposal) { create(:proposal, state: Proposal::State::ACCEPTED) }
  let(:organizer) { create(:organizer, event: proposal.event) }

  before { login_as(organizer) }

  context "Viewing the program" do
    it "can view the program" do
      pending("need to convert this to work with the new ProgramSessions#index")
      fail
      # visit event_staff_program_path(proposal.event)
      # expect(page).to have_text("#{proposal.event.name} Program")
      # expect(page).to have_text(proposal.title)
    end
  end

  context "Viewing a proposal" do
    it "links back button to the program page" do
      pending("fix? smart back button not in organizer's new review flow")
      fail
      #BROKEN: depends on 'smart_back_button'
      # visit event_staff_program_path(proposal.event)
      # visit event_staff_proposal_path(proposal.event, proposal)
      # back = find('#back')
      # expect(back[:href]).to eq(event_staff_program_path(proposal.event))
    end
  end
end
