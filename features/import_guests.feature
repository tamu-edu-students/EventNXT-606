Feature: Import guests from Ticketmaster
  
  Scenario: Importing guests with valid event ID and API key
    Given I have a valid event ID "2000527EE48A9334" and API key "HAuyG5PbQX71SLAVgAzc2KtVPwaJrXNe" 
    And the following guests are registered for the event:
    | First Name | Last Name | Email | Seat Level | Number of Seats |
    | John | Smith | john.smith@example.com | General Admission | 3 |
    | Jane | Doe | jane.doe@example.com | VIP | 2 |
    When I import guests from Ticketmaster
    Then the guest list should be saved successfully

  Scenario: Importing guests with invalid event ID or API key
    Given I have an invalid event ID or API key
    When I import guests from Ticketmaster
    Then the guest list should not be saved


