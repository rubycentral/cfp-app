Feature: A user can update his/her profile

  Background:
    Given I am logged on as a user
      And I am on the edit profile page

  Scenario: A user can save demographics info
    Given I set up my demographics information
     When I save the profile form
     Then my demographics data is updated

  Scenario: A user can change the demographics info
    Given I change my demographics information
     When I save the profile form
     Then my demographics data is changed

  Scenario: A user can save the bio
    Given I set up my bio
     When I save the profile form
     Then my bio is updated

  Scenario: A user can change the bio
    Given I change my bio
     When I save the profile form
     Then my bio is changed
