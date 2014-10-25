Feature: A user can update his/her profile

  Scenario: A user can save demographics info
    Given I am logged on as a user
      And I am on the edit profile page
      And I set up my demographics information
     When I save the profile form
    Then my demographics data is updated

  Scenario: A user can change the demographics info
    Given I am logged on as a user
      And I am on the edit profile page
      And I change my demographics information
     When I save the profile form
    Then my demographics data is changed
