#!/bin/zsh

# Change to the Rails root directory
cd "$(dirname "$0")/.." || exit

# Start the Rails server in the background
rails s -p 3005 -d

# Wait for the server to start
sleep 5

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Base URL for API requests
BASE_URL="http://localhost:3005"

# Function to check response
check_response() {
    if [[ $1 == *"$2"* ]]; then
        echo "${GREEN}Pass: $3${NC}"
        return 0
    else
        echo "${RED}Fail: $3${NC}"
        echo "Expected: $2"
        echo "Got: $1"
        return 1
    fi
}

# Variable to track overall success
all_passed=true

# Setup database
rails db:drop && rails db:create && rails db:migrate

# Run tests and linter
bundle exec rspec
bundle exec rubocop -A
# Run RuboCop and capture its exit code
rubocop_exit_code=$?

# User Registration
echo "\nTesting User Registration:"
response=$(curl -s -X POST "${BASE_URL}/users" \
  -H "Content-Type: application/json" \
  -d '{"user": {"email": "testuser@example.com","password": "password123","password_confirmation": "password123","date_of_birth": "2000-01-01"}, "profile": {"first_name": "Test", "last_name": "User", "age": 23, "username": "testuser", "description": "A test user", "occupation": "Tester"}}' )
check_response "$response" "Signed up successfully." "User Registration" || all_passed=false

# User Registration (existing user)
echo "\nTesting User Registration (existing user):"
response=$(curl -s -X POST "${BASE_URL}/users" \
  -H "Content-Type: application/json" \
  -d '{"user": {"email": "testuser@example.com","password": "password123","password_confirmation": "password123","date_of_birth": "2000-01-01"}}' )
check_response "$response" "User couldn't be created successfully. Email has already been taken" "User Registration (existing user)" || all_passed=false

# User Login
echo "\nTesting User Login:"
response=$(curl -s -X POST "${BASE_URL}/users/sign_in" \
  -H "Content-Type: application/json" \
  -d '{"user": {"email": "testuser@example.com","password": "password123"}}' )
check_response "$response" "Logged in successfully" "User Login" || all_passed=false

# Extract token for subsequent tests
token=$(echo $response | jq -r '.data.token' )

token=$(echo $response | jq -r '.data.token')

if [ -z "$token" ]; then
  echo "Failed to extract token. Cannot proceed with authenticated tests."
  exit 1
fi

# View Profile
echo "\nTesting View Profile:"
response=$(curl -s -X GET "${BASE_URL}/profile" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json")
check_response "$response" "name" "View Profile" || all_passed=false

# Update Profile
echo "\nTesting Update Profile:"
response=$(curl -s -X PUT "${BASE_URL}/profile" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json" \
  -d '{"profile": {"first_name": "John", "last_name": "Doe", "age": 25, "username": "johndoe", "description": "A software developer", "occupation": "Developer"}}')
check_response "$response" "John" "Update Profile" || all_passed=false

# View Updated Profile
echo "\nTesting View Updated Profile:"
response=$(curl -s -X GET "${BASE_URL}/profile" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json")
check_response "$response" "John Doe" "View Updated Profile" || all_passed=false
# Attempt to login again (should fail as already logged in)
echo "\nTesting Login when already logged in:"
response=$(curl -s -X POST "${BASE_URL}/users/sign_in" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $token" \
  -d '{"user": {"email": "testuser@example.com","password": "password123"}}' )
check_response "$response" "You are already logged in" "Login when already logged in" || all_passed=false

# User Login (incorrect credentials)
echo "\nTesting User Login (incorrect credentials):"
response=$(curl -s -X POST "${BASE_URL}/users/sign_in" \
  -H "Content-Type: application/json" \
  -d '{"user": {"email": "testuser@example.com","password": "wrongpassword"}}' )
check_response "$response" "Invalid Email or password" "User Login (incorrect credentials)" || all_passed=false

# User Logout
echo "\nTesting User Logout:"
response=$(curl -s -X DELETE "${BASE_URL}/users/sign_out" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json")
check_response "$response" "Logged out successfully" "User Logout" || all_passed=false

# Attempt to logout again (should fail as no one is logged in)
echo "\nTesting Logout when not logged in:"
response=$(curl -s -X DELETE "${BASE_URL}/users/sign_out" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json")
check_response "$response" "No active session" "Logout when not logged in" || all_passed=false

# Final result
if $all_passed; then
    echo "\n${GREEN}All tests passed successfully!${NC}"
else
    echo "\n${RED}Some tests failed. Please check the output above.${NC}"
fi

# Summary report
echo "\n=== Test Results ==="

# RSpec results
rspec_output=$(bundle exec rspec 2>&1)
rspec_summary=$(echo "$rspec_output" | grep "[0-9]* examples, [0-9]* failures")
echo "RSpec: $rspec_summary"

# Coverage
coverage=$(awk -F':' '/"line":/ {print $2}' coverage/.last_run.json | tr -d ' ,')
echo "Coverage: ${coverage:-N/A}%"

# RuboCop offenses
rubocop_output=$(bundle exec rubocop 2>&1)
rubocop_summary=$(echo "$rubocop_output" | grep "files inspected," | tail -n 1)
echo "RuboCop: $rubocop_summary"

# Curl test results
curl_failures=0
echo "Curl tests: $curl_failures failures"

# Overall result
rspec_summary=$(echo "$rspec_output" | grep "[0-9]* examples, [0-9]* failures")
coverage_value=$(awk -F':' '/"line":/ {print $2}' coverage/.last_run.json | tr -d ' ,')
rubocop_offenses=$([ $rubocop_exit_code -eq 0 ] && echo "0" || echo "1")

if [ "${rspec_failures:-0}" = "0" ] &&
   [ "${coverage_value:-0}" = "100.0" ] &&
   [ "${curl_failures:-0}" -eq 0 ] &&
   [ "${rubocop_offenses:-1}" -eq 0 ] &&
   [ "${all_passed:-false}" = "true" ]; then
    echo "\n${GREEN}All tests and checks passed successfully"
else
    echo "\n${RED}Some tests or checks failed. Please review the summary above.${NC}"
    echo "Failed conditions:"
    [ "${rspec_failures:-0}" != "0" ] && echo "- RSpec failures: $rspec_failures"
    [ "${coverage_value:-0}" != "100.0" ] && echo "- Coverage not 100%"
    [ "${curl_failures:-0}" -ne 0 ] && echo "- Curl failures: $curl_failures"
    [ "${rubocop_offenses:-1}" -ne 0 ] && echo "- RuboCop offenses detected"
    [ "${all_passed:-false}" != "true" ] && echo "- All passed flag not true"
fi