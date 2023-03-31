Feature: Navigate to Home Page
  As a user on the register page
  I want to be able to click the Home button in the navbar
  So that I can quickly return to the Home page

  Background:
    Given I am a user
    And I am on the register page

  Scenario: Clicking Home button redirects to Home page
    When I click the "Home" button in the navbar
    Then I should be on the Home page
