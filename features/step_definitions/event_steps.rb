# * http://benmabey.com/2008/05/19/imperative-vs-declarative-scenarios-in-user-stories.html
# * http://dannorth.net/2011/01/31/whose-domain-is-it-anyway/
# * http://elabs.se/blog/15-you-re-cuking-it-wrong
# Given /^the following events exist$/ do |table|
#   require 'date'
#   table.hashes.each { |h|
#     h['datetime'] = Date.parse h['datetime']
#     h['last_modified'] = Date.parse h['last_modified']
#     create :event, h
#   }
# end

Given(/^the following events exist$/) do |table|
  table.hashes.each do |event|
    # code to create event in the database
    Event.create event
  end
end

# Given /^I access "(.+)"$/ do |url|
#   @url = url
# end

# When /^I post an image parameter$/ do
#   event = build :event
#   @response = patch @url, params: { image: event.image }
# end

# Then /^I should get a successful response$/ do
#   expect(@response).to be_successful
# end

Given(/^I access "(.*?)"$/) do |url|
  visit url
end

When(/^I fill field "(.*?)" with "(.*?)"$/) do |field, value|
  fill_in field, with: value
end

When(/^I click on "(.*?)"$/) do |button|
  click_on button
end

Then(/^I should get a successful response$/) do
  expect(page.status_code).to eq(200)
end

Given(/^I am at "(.*?)"$/) do |url|
  visit url
end

When(/^I fill "(.*?)" with "(.*?)"$/) do |field, value|
  fill_in field, with: value
end

When(/^I click "(.*?)" button$/) do |button|
  click_on button
end

# Then("I should see {string}") do |text|
#   expect(page).to have_content(text)
# end

Then(/^I should land on login page$/) do
  url = "/"
  visit url
end
