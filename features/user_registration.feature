Feature: User registration

  Scenario: User successfully registers
    Given I am on the registration page
    When I fill in the registration form with valid data
    And I click the "Create" button
    Then I should be redirected to the root page

