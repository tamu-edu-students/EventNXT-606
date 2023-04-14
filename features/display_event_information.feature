###### amin --- undefined

Feature: manage the event-related information

  As an event owner 
  I want to see all the summarized event-related information in the control room
  So that I can manage the tickets accordingly

Background: guests of an event in database

  Given the following events exist:
  | id        | title     | date        |
  | 1         | Fashion   | 10/01/2019  |
  
  Given the following guests exist:
  | event_id  | id    | first_name | last_name  | email_address   | seat_category | max_seats_num | booking_status  | total_booked_num
  | 1         | 1     | Sim        | Amy        | sim@gmail.com   | R1            | 1             | Invited         | 1
  | 1         | 2     | Holmes     | Join       | join@gmail.com  |               |               | Not invited     | 0

Scenario: go to "The Control Room"
  Given I am on the main page "EVENTNXT"
  When I fill in "Username" with "Alice"
  And I fill in "Password" with "123456"
  And I fill in "Name of the Event" with "some fashion event"
  And I press "Create"
  Then I should see "The Control Room"

Scenario: Add VIP Guests
  Given I am on the page for "The Control Room"
  Then I should see "VIP Guest List"
  And I should see "Box Office List"
  When I fill in "Email Address" with "alice@tamu.edu"
  And I fill in "First name" with "Alice"
  And I fill in "Last name" with "Bonyoma"
  And I fill in "Affiliation" with "TAMU"
  And I fill in "Added by" with "bbb"
  And I fill in "Guest type" with "ccc"
  And I fill in "Seat category" with "R1"
  And I fill in "Max seats num" with "3"
  And I press "Add"
  Then I should see "alice@tamu.edu", "Alice", "Bonyoma", "TAMU", "bbb", "ccc", "R1", "3" in the VIP Guest List

Scenario: update VIP guest information
  When I click on the email address "alice@tamu.edu"
  And I fill in "alicealice@tamu.edu" in place
  Then I should see "alicealice@tamu.edu"
