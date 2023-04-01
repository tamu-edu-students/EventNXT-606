Given("the following user exists:") do |table|
  # Create users from the table
  table.hashes.each do |hash|
    User.create(hash)
  end
end

Given("I am an admin") do
  # Set current user as an admin
  @current_user = User.find_by(is_admin: true)
end

When("I send a GET request to {string}") do |path|
  # Send a GET request to the specified path with authorization headers
  headers = @current_user ? { 'Authorization' => @current_user.token } : {}
  get path, headers: headers
end

When("I send a PUT request to {string} with the following parameters:") do |path, table|
  # Send a PUT request to the specified path with authorization headers and parameters
  params = table.rows_hash
  headers = @current_user ? { 'Authorization' => @current_user.token } : {}
  put path, params: params, headers: headers
end

When("I send a DELETE request to {string}") do |path|
  # Send a DELETE request to the specified path with authorization headers
  headers = @current_user ? { 'Authorization' => @current_user.token } : {}
  delete path, headers: headers
end

Then(/^the response status should be (nil|\d+)$/) do |status|
  expect(response.status).to eq(status.to_i) unless status == 'nil'
end

Then("the response status should be 200") do
  expect(response.status).to eq(200)
end



Then("the response body should be empty") do
  # Check if the response body is empty
  expect(response.body).to be_empty
end

Then("the response body should contain the following users:") do |table|
  # Check if the response body contains the users from the table
  users = JSON.parse(response.body)
  expected_users = table.hashes
  expect(users).to match_array(expected_users)
end

Then("the response body should contain the following user:") do |table|
  # Check if the response body contains the user from the table
  user = JSON.parse(response.body)
  expected_user = table.rows_hash
  expect(user).to include(expected_user)
end

Then("the response body should contain an error message") do
  # Check if the response body contains an error message
  error = JSON.parse(response.body)
  expect(error).to include('error')
end
