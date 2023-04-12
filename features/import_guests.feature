Feature: Import guests from Ticketmaster

  Scenario: Importing guests with valid event ID and API key
    Given I have a valid event ID "2000527EE48A9334" and API key "HAuyG5PbQX71SLAVgAzc2KtVPwaJrXNe"
    When I import guests from Ticketmaster
    Then the guest list should be saved successfully

  Scenario: Importing guests with invalid event ID or API key
    Given I have an invalid event ID or API key
    When I import guests from Ticketmaster
    Then the guest list should not be saved
