require 'rails_helper'

feature "Organizers can manage the program" do

  let(:proposal) { create(:proposal_with_track, state: Proposal::State::ACCEPTED) }
  let(:organizer) { create(:organizer, event: proposal.event) }

  before { login_as(organizer) }

  context "Viewing the program" do
    it "can view the program" do
      pending("need to convert this to work with the new ProgramSessions#index")
      fail
    end
  end

  context "Viewing a proposal" do
    it "links back button to the program page" do
      pending("fix? smart back button not in organizer's new review flow")
      fail
    end
  end
end
