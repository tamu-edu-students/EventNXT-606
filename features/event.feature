###### amin --- 4 steps (1 failed, 2 skipped, 1 undefined)

Feature: upload image to the event
  I want to attach an image for the event

Background: event in database
  Given the following events exist
  | id        | title     | address     | datetime        | last_modified |
  | 1         | Fashion   | 123 Example | 10/10/2022      | 10/02/2019    |

Scenario: upload image under event 1
  Given I access "/api/v1/events/1"
  When I post an image parameter
  Then I should get a successful response