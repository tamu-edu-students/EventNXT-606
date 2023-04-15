Feature: Adding an event to the dashboard
  As an user
  I want to be able to create an event
  So that I can keep track of my events in my dashboard

  Scenario: User adds an event to their dashboard
    Given I am at "events" homepage
    When I click on the "Add"
    Then I should see a form with id "event-modal" pop up
    When I fill in the following details:
      | title      | My Event             |
      | address    | 123 Main St          |
      | description| A fun event for all  |
      | datetime   | 2023-06-30 12:00 PM  |
    And I click on the "Create" button
    Then I should see the new event page