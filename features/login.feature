Feature: Logging on as a developer

  Scenario: Logging on with correct credentials
    Given I am a user
     When I log on
     Then I should be logged on
