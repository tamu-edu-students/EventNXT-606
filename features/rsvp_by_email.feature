###### amin --- 19 steps (1 skipped, 18 undefined)

Feature: event owner manages the tickets with VIP guests through RSVP email 

  As an event owner 
  I want to send event invitation email with RSVP link to a specific VIP guest
  So that I can invite them to the event with a maximum ticket number

Background: guests of an event in database

  Given the following events exist:
  | id        | title     | date        |
  | 1         | Fashion   | 10/01/2019  |
  
  Given the following guests exist:
  | event_id  | id    | first_name | last_name  | email_address   | seat_category | max_seats_num | booking_status  | total_booked_num
  | 1         | 1     | Sim        | Amy        | sim@gmail.com   | R1            | 1             | Invited         | 1
  | 1         | 2     | Holmes     | Join       | join@gmail.com  |               |               | Not invited     | 0

Scenario: add seat category and maximum seats number to existing VIP guest
  When I go to the show page for "Fashion"
  And  I fill in "seat_category" with "Standing" for "Holmes Join"
  And  I fill in "max_seats_num" with "2" for "Holmes Join"
  Then the seat category of "Holmes Join" should be "Standing"
  And the max seats num of "Holmes Join" should be "2"

Scenario: send email invitation to existing VIP guest
  Given I am on the show page for "Fashion"
  When  I click "Send" in the row of guest "Holmes Join"
  Then  the booking_status of "Holmes Join" should be "Invited"
  And   the total booked numbers of "Holmes Join" should be "0"
  And   I should see "The email was successfully sent to Holmes Join."

Scenario: receive email confirmation from existing VIP guest
  Given I am on the show page for "Fashion"
  When  I receive email confirmation from guest "Holmes Join"
  Then  the booking_status of "Holmes Join" should be "Yes" or "No"
