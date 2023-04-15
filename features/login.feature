Feature: User login

  Scenario: User successfully logs in
    Given a registered user with email "john.doe@example.com" and password "password123"
    And I am on the login page
    When I fill in the login form with email "john.doe@example.com" and password "password123"
    And I click the Log in button
    Then I should be redirected to the events page
    And I should see a successful login message
