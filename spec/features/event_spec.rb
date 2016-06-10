require 'rails_helper'

feature "Listing events for different roles" do
  let(:event) { create(:event, state: 'open') }
  let!(:proposal) { create(:proposal, title: "A Proposal", abstract: 'foo', event: event) }
  let(:normal_user) { create(:user) }
  let(:organizer) { create(:user) }

  context "As a regular user" do
    scenario "the user should see a link to to the proposals for an event" do
      login_user(normal_user)
      visit events_path
      expect(page).to have_link('1 proposal', href: event_path(event.slug))
    end
  end

  context "As an organizer" do
    scenario "the organizer should see a link to the index for managing proposals" do
      create(:participant, role: 'organizer', user: organizer)
      login_user(organizer)
      visit events_path
      expect(page).to have_link('1 proposal', href: organizer_event_proposals_path(event))
    end
  end
end
