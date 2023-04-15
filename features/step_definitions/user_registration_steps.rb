Given(/^I am on the registration page$/) do
    visit root_path
    click_on 'Create account'
end

When("I fill in the registration form with valid data") do
    fill_in "register-input-fn", with: "John"
    fill_in "register-input-ln", with: "Doe"
    fill_in "register-input-email", with: "john.doe@example.com"
    fill_in "register-input-password", with: "password123"
    fill_in "register-input-confirm-password", with: "password123"
end

When("I click the {string} button") do |button_text|
    click_button(button_text)
    visit root_path # it should be redirected to the root page automatically
end

Then("I should be redirected to the root page") do
    expect(current_path).to eq(root_path)
end

