Given("I am a registered user") do
    @user = create(:user, email: "bebop.quinn@tamu.edu", password: "Bebop2023")
  end
  
  Given("I am on the login page") do
    visit root_path
  end
  
  When("I fill in {string} with {string}") do |field, value|
    fill_in field, with: value
    save_and_open_page
  end
  
  When("I click the {string} button") do |button_name|
    click_button button_name
  end
  
  Then("I should be on my events page") do
    expect(page).to have_content("My Events")
  end
  
  Then("I should see {string}") do |content|
    expect(page).to have_content(content)
  end
  