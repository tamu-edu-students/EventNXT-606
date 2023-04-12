require 'net/http'

Given(/^I have a valid event ID "(.*?)" and API key "(.*?)"$/) do |event_id, api_key|
  @guest_import = GuestsImport.new(event_id: event_id, api_key: api_key)
end

Given(/^I have an invalid event ID or API key$/) do
  @guest_import = GuestsImport.new(event_id: nil, api_key: nil)
end

When(/^I import guests from Ticketmaster$/) do
  @result = @guest_import.save
end

Then(/^the guest list should be saved successfully$/) do
  expect(@result).to be true
end

Then(/^the guest list should not be saved$/) do
  expect(@result).to be false
end
