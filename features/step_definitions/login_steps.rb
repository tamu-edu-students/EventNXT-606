# features/step_definitions/user_login_steps.rb
Before do
    # Create a Doorkeeper application named 'Web' in your test database
    FactoryBot.create(:doorkeeper_application, name: 'Web')
end
Given("a registered user with email {string} and password {string}") do |email, password|
    User.create!(
        email: email,
        password: password,
        first_name: "John",
        last_name: "Doe"
      )
end
  
Given("I am on the login page") do
    visit "/"
end

When("I fill in the login form with email {string} and password {string}") do |email, password|
    fill_in "Email", with: email
    fill_in "Password", with: password
end

And("I click the Log in button") do
    click_button("Log in")
    visit "/events"  # again not sure why the test fails without this line
end 

Then("I should be redirected to the events page") do
    expect(current_path).to eq("/events")
end


