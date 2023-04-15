Given("I am logged in as a user") do
    # Implementation to log in as a user
    user = FactoryBot.create(:user)
    visit root_path
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"
end

When("I visit the root page") do
    # Implementation to visit the root page
    visit root_path
end

And("I click on the {string} button") do |button_text|
    # Implementation to click the "Log out" link
    click_button button_text
end

Then("I should see a {string} message") do |message|
    # Implementation to verify the "Signed out successfully" message is displayed
    expect(page).to have_content message
end