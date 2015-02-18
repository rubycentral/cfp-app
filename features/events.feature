Feature: Listing events for different roles

  Scenario: A user sees a link to the proposals for an event
    Given I am logged on as a user
      And I entered one proposal for an event
     When I am on the events page
     Then I should see a link to my proposal

  Scenario: An organizer sees a link to the index for managaing proposals
    Given I am logged on as an organizer
      And a user entered one proposal for an event
     When I am on the events page
     Then I should see a link to manage proposals

