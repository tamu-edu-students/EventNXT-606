# Given("I am at {string}") do |path|
#   visit path
# end

# When("I click on the {string} button") do |button_text|
#   click_on button_text
# end

Then("I should see a form with id {string} pop up") do |form_id|
  expect(page).to have_css("##{form_id}")
end

When("I fill in the following details:") do |table|
  details = table.rows_hash
  fill_in "event_name", with: details["event_name"]
  fill_in "event_Address", with: details["event_Address"]
  fill_in "event_Description", with: details["event_Description"]
  fill_in "event_datetime", with: details["event_datetime"]
end

When("I click on the {string} button") do |button_text|
  click_on button_text
end

Then("I should see the new event added to the dashboard path") do
  expect(page).to have_content("My Event")
  expect(page).to have_content("123 Main St")
  expect(page).to have_content("A fun event for all")
  expect(page).to have_content("April 30, 2023 12:00 PM")
end
