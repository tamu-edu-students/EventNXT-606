<<<<<<< HEAD
Feature: User registration

  Scenario: User successfully registers
    Given I am on the registration page
    When I fill in the registration form with valid data
    And I click the "Create" button
    Then I should be redirected to the root page

=======
Feature: User can create an account
  As a new user
  I want to be able to register an account
  So that I can have personal events dashboard

  Scenario: User should be able to register with valid credentials
    Given I am at "?register"
    When I fill "register-input-fn" with "user_fn"
    And I fill "register-input-ln" with "user_ln"
    And I fill "register-input-email" with "user_email"
    And I fill "register-input-password" with "user_pass"
    And I fill "register-input-confirm-password" with "user_confirmPass"
    And I click "Create" button
    #Then I should see "A new account is created!"
    Then I should land on login page
>>>>>>> 4d66d4f0b2acbe7601e3ffbd8a48874a3535faba
