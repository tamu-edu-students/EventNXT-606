Feature: Users API

  Background:
    Given the following user exists:
       | first_name       | last_name|email            | is_admin | deactivated |
        | John | Doe |john@example.com | true     | false       |
        | Jane   | Doe| jane@example.com | false    | false       |

  Scenario: List users
    When I send a GET request to "/api/v1/users"
    Then the response status should be nil
    And the response body should be empty

    Given I am an admin
    When I send a GET request to "/api/v1/users"
    Then the response status should be 200
    And the response body should contain the following users:
       | first_name       |last_name| email            | is_admin | deactivated |
        | John |Doe |john@example.com | true     | false       |
        | Jane   | Doe|jane@example.com | false    | false       |

  Scenario: Show user
    When I send a GET request to "/api/v1/users"
    Then the response status should be 200
    And the response body should contain the following user:
       | first_name | last_name      | email            | is_admin | deactivated |
        | John | Doe|john@example.com | true     | false       |

    When I send a GET request to "/api/v1/users"
    Then the response status should be 404
    And the response body should contain an error message

  Scenario: Update user
    When I send a PUT request to "/api/v1/users" with the following parameters:
      | is_admin | deactivate |
      | false    | true       |
    Then the response status should be 200
    And the response body should contain the following user:
       | full_name       | email            | is_admin | deactivated |
        | John Smith| john@example.com | false    | true        |

    When I send a PUT request to "/api/v1/users" with the following parameters:
      | is_admin | deactivate |
      | false    | true       |
    Then the response status should be 404
    And the response body should contain an error message

  Scenario: Deactivate user 
    When I send a DELETE request to "/api/v1/users/true"
    Then the response status should be 200

    When I send a GET request to "/api/v1/users"
    Then the response status should be 404 
    And the response body should contain an error message
