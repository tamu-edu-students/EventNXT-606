Given("I am a user") do
    # Create a user in your app's database
    @user = create(:user)
end
  
Given("I am on the register page") do
    # Navigate to the register page using Capybara
	 visit root_path(register: true)
	 save_and_open_page
end

When("I click the {string} button in the navbar") do |button_name|
	within('nav') do
	  click_link(button_name)
	end
end
 
Then("I should be on the Home page") do
	expect(page).to have_current_path(root_path)
end
 