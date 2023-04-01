Feature: add guest to the event
  I want to add guest for the event

Background: event in database
  Given the following events exist
  | id        | title     | address     | datetime |
  | 11         | Fashion   | 123 Example | 10/10/2024 12:00:00 |

Scenario: verify user is able to add guest to event successfully
  Given I access "/events/11"
  When I fill field "guest-add-fn" with "Fname"
  And I fill field "guest-add-ln" with "Lname"
  And I fill field "guest-add-email" with "F_Lname@gmail.com"
  And I click on "Add Guest"
  Then I should get a successful response
  
    
