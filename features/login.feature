###### amin --- 12 steps (2 failed, 6 skipped, 4 passed)

Feature: User can login and view events
  As a registered user
  I want to be able to login and view my events
  So that I can manage my events

  Background:
    Given I am a registered user
    And I am on the login page

  Scenario: Login with valid credentials
    When I fill in "Email" with "bebop.quinn@tamu.edu"
    And I fill in "Password" with "Bebop2023"
    And I click the "Login" button
    Then I should be on my events page

  Scenario: Login with invalid credentials
    When I fill in "Email" with "invaliduser@example.com"
    And I fill in "Password" with "invalidpassword"
    And I click the "Login" button
    Then I should see "Invalid email or password"
