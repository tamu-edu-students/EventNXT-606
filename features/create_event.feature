Feature: Adding an event to the dashboard
  
  Scenario: User adds an event to their dashboard
    Given I am logged in as a registered user
    And I am on the event dashboard path
    When I click on the "Add Event" button
    Then I should see a form with id "form-event" pop up
    When I fill in the following details:
      | event_name       | My Event             |
      | event_Address    | 123 Main St          |
      | event_Description| A fun event for all  |
      | event_datetime   | 2023-04-30 12:00 PM  |
    And I click on the "Create" button
    Then I should see the new event added to the dashboard path
