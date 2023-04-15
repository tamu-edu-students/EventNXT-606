Feature: Adding an event to the dashboard
  As an user
  I want to be able to create an event
  So that I can keep track of my events in my dashboard
  
  Scenario: User adds an event to their dashboard
    Given I am at "events"
    When I click on the "Add" button
    Then I should see a form with id "form-event" pop up
    When I fill in the following details:
      | event_name       | My Event             |
      | event_Address    | 123 Main St          |
      | event_Description| A fun event for all  |
      | event_datetime   | 2023-04-30 12:00 PM  |
    And I click on the "Create" button
    Then I should see the new event added to the dashboard path
