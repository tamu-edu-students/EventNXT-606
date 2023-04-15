Feature: User log out

  Scenario: User successfully logs out
    Given I am logged in as a user
    When I visit the root page
    And I click on the "Log out" button
    Then I should see a "Signed out successfully" message
