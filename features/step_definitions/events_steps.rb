Given(/^I entered one proposal for an event$/) do
  event = FactoryGirl.create(:event, state: 'open')
  FactoryGirl.create(:proposal, title: "A Proposal", abstract: 'foo', event: event)
end

Given(/^I am logged on as an organizer$/) do
  organizer = FactoryGirl.create(:person)
  participant_organizer = FactoryGirl.create(:participant,
                                             role: 'organizer',
                                             person: organizer)
  expect(Person.count).to eq 1
  login_user(organizer)
end

Given(/^a user entered one proposal for an event$/) do
  event = Event.last

  FactoryGirl.create(:proposal, title: "A Proposal", abstract: 'foo', event: event)
end

When(/^I am on the events page$/) do
  page.visit events_path
end

Then(/^I should see a link to my proposal$/) do
  event = Event.last
  expect(page).to have_link('1 proposal', href: event_path(event.slug))
end

Then(/^I should see a link to manage proposals$/) do
  event = Event.last
  expect(page).to have_link('1 proposal', href: organizer_event_proposals_path(event))
end
