Given(/^I am at "(.*?)" homepage$/) do |url|
  visit url
end
When("I click on the {string}") do |text|
  # Find the button element using its text content
  button = find('p.card-text', text: text)

  # Click on the button
  button.click
end

Then("I should see a form with id {string} pop up") do |form_id|
  expect(page).to have_css("##{form_id}")
end

When("I fill in the following details:") do |table|
  details = table.rows_hash
  fill_in "title", with: details["event_name"]
  fill_in "address", with: details["event_Address"]
  fill_in "description", with: details["event_Description"]
  fill_in "datetime", with: details["event_datetime"]
end

When("I click on the {string} button") do |button_text|
  click_on button_text
end

Then("I should see the new event page") do
  expect(page.status_code).to eq(200)
end