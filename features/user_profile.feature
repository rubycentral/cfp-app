Feature: A user can update his/her profile

  Background:
    Given I am logged on as a user
      And I am on the edit profile page

  Scenario Outline: A user can add profile information
    Given I set up my <subject>
     When I save the profile form
     Then my <subject> is updated

  Examples:
      | subject           |
      | demographics info |
      | bio               |

  Scenario Outline: A user can change profile information
    Given I change my <subject>
     When I save the profile form
     Then my <subject> is changed

  Examples:
      | subject           |
      | demographics info |
      | bio               |
