require 'rails_helper'

feature "Listing events for different roles" do
  let(:event) { create(:event, name: "Greens Event", state: 'open') }
  let!(:proposal) { create(:proposal, title: "A Proposal", abstract: 'foo', event: event) }
  let(:normal_user) { create(:user) }
  let(:organizer) { create(:user) }

  context "As a regular user" do
    scenario "the user should see a link to the CFP page for the event" do
      login_as(normal_user)
      visit events_path
      expect(page).to have_link("Greens Event", href: event_path(event))
    end
  end

  context "As an organizer" do
    scenario "the organizer should see a link to the guidelines page for an event" do
      create(:teammate, role: 'organizer', user: organizer)
      login_as(organizer)
      visit events_path
      expect(page).to have_link("Greens Event", href: event_path(event))
    end
  end

  context "Event CFP page" do
    scenario "the user sees proper stats" do
      skip "FIX ME, WHICH USER?! 'the user' is far too generic. Also why is it failing with 1 day off?"
      visit event_path(event)

      expect(page).to have_content event.name
      expect(page).to have_link 'Submit a proposal'
      expect(page).to have_content "Closes at #{(DateTime.now + 21.days).strftime('%b %-d')}"
      expect(page).to have_content '21 days left to submit your proposal'
      expect(page).to have_content '1 proposal submitted'
    end

    scenario "the event title is a link if it's set" do
      new_event = Event.create(name: "Coolest Event", slug: "cool", url: "", state: "open", closes_at: DateTime.current + 21.days)
      visit event_path(new_event)

      within('.page-header') do
        expect(page).to have_content "Coolest Event"
        expect(page).to_not have_link new_event.name
      end
    end
  end
end
