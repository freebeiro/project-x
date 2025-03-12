#!/bin/zsh

# Change to the Rails root directory
cd "$(dirname "$0")/.." || exit

# Kill any existing Rails server on port 3005
lsof -ti:3005 | xargs kill -9 2>/dev/null || true

# Remove any stale pid file
rm -f tmp/pids/server.pid

# Load environment variables from .env if it exists
if [ -f .env ]; then
  echo "Loading environment variables from .env file"
  export $(grep -v '^#' .env | xargs)
fi

# Start the Rails server in the background
RAILS_ENV=development rails s -p 3005 -d

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
       if [[ $1 == *"traces"* ]]; then
            error_message=$(echo "$1" | grep -o '{.*}' | head -n 1 | sed 's/,"traces":.*//')
        else
            error_message="$1"
        fi
        echo "${RED}Fail: $3${NC}"
        echo "Expected: $2"
        #echo "Got: $1"
        echo "Got: $error_message"
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
token=$(echo $response | jq -r '.data.token')

if [ -z "$token" ]; then
  echo "Failed to extract token. Cannot proceed with authenticated tests."
  exit 1
fi

# Extract user ID for the main user
main_user_id=$(echo $response | jq -r '.data.id')

# Create a friend user
echo "\nCreating a friend user:"
response=$(curl -s -X POST "${BASE_URL}/users" \
  -H "Content-Type: application/json" \
  -d '{"user": {"email": "friend@example.com","password": "password123","password_confirmation": "password123","date_of_birth": "2000-01-01"}, "profile": {"first_name": "Friend", "last_name": "User", "age": 23, "username": "frienduser", "description": "A friend user", "occupation": "Friend"}}' )
check_response "$response" "Signed up successfully." "Friend User Registration" || all_passed=false

# Search for friend user
echo "\nSearching for friend user:"
response=$(curl -s -X GET "${BASE_URL}/users/search?username=frienduser" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json")
check_response "$response" "id" "Search Friend User" || all_passed=false

# Extract friend user ID
friend_user_id=$(echo $response | jq -r '.id')

# Print the friend_user_id for debugging
echo "Friend User ID: $friend_user_id"

# Create friendship with friend user
echo "\nCreating friendship with friend user:"
response=$(curl -s -X POST "${BASE_URL}/friendships" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json" \
  -d "{\"friendship\": {\"friend_username\": \"frienduser\"}}")
check_response "$response" "Friendship request sent successfully" "Create Friendship" || all_passed=false

# Login as friend user to accept friendship
echo "\nLogging in as friend user:"
response=$(curl -s -X POST "${BASE_URL}/users/sign_in" \
  -H "Content-Type: application/json" \
  -d '{"user": {"email": "friend@example.com","password": "password123"}}' )
check_response "$response" "Logged in successfully" "Friend User Login" || all_passed=false

# Extract token for friend user
friend_token=$(echo $response | jq -r '.data.token')

# Before accepting friendship, search for main user
echo "\nSearching for main user:"
response=$(curl -s -X GET "${BASE_URL}/users/search?username=testuser" \
  -H "Authorization: Bearer $friend_token" \
  -H "Content-Type: application/json")
check_response "$response" "id" "Search Main User" || all_passed=false

# Extract main user ID
main_user_id=$(echo $response | jq -r '.id')

# Accept friendship request
echo "\nAccepting friendship request:"
response=$(curl -s -X PUT "${BASE_URL}/friendships/accept" \
  -H "Authorization: Bearer $friend_token" \
  -H "Content-Type: application/json" \
  -d "{\"friendship\": {\"friend_id\": $main_user_id}}")
check_response "$response" "Friendship accepted successfully" "Accept Friendship" || all_passed=false

# View own profile (main user)
echo "\nViewing own profile:"
response=$(curl -s -X GET "${BASE_URL}/profile" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json")
check_response "$response" "first_name" "View Own Profile" || all_passed=false

# View friend's profile
echo "\nViewing friend's profile:"
response=$(curl -s -X GET "${BASE_URL}/profiles/${friend_user_id}" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json")
check_response "$response" "first_name" "View Friend's Profile" || all_passed=false

# Create a non-friend user
echo "\nCreating a non-friend user:"
response=$(curl -s -X POST "${BASE_URL}/users" \
  -H "Content-Type: application/json" \
  -d '{"user": {"email": "nonfriend@example.com","password": "password123","password_confirmation": "password123","date_of_birth": "2000-01-01"}, "profile": {"first_name": "NonFriend", "last_name": "User", "age": 23, "username": "nonfrienduser", "description": "A non-friend user", "occupation": "NonFriend"}}' )
check_response "$response" "Signed up successfully." "Non-Friend User Registration" || all_passed=false

# Extract non-friend user ID
non_friend_user_id=$(echo $response | jq -r '.data.id')

# View non-friend's profile
echo "\nViewing non-friend's profile:"
response=$(curl -s -X GET "${BASE_URL}/profiles/${non_friend_user_id}" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json")
check_response "$response" "username" "View Non-Friend's Profile" || all_passed=false
if [[ $response == *"first_name"* ]]; then
  echo "${RED}Fail: Non-friend's profile should not include first_name${NC}"
  all_passed=false
fi

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

# Create a Group
echo "\nTesting Create Group:"
response=$(curl -s -X POST "${BASE_URL}/groups" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json" \
  -d '{"group": {"name": "Test Group", "description": "A test group", "privacy": "public", "member_limit": 10}}')
check_response "$response" "Group created successfully" "Create Group" || all_passed=false

# Extract group_id from the response
group_id=$(echo $response | jq -r '.data.id')

# View Group
echo "\nTesting View Group:"
response=$(curl -s -X GET "${BASE_URL}/groups/${group_id}" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json")
check_response "$response" "Test Group" "View Group" || all_passed=false

# Join Group
echo "\nTesting Join Group:"
response=$(curl -s -X POST "${BASE_URL}/groups/${group_id}/group_membership" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json")
check_response "$response" "Successfully joined the group" "Join Group" || all_passed=false

# Leave Group
echo "\nTesting Leave Group:"
response=$(curl -s -X DELETE "${BASE_URL}/groups/${group_id}/group_membership" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json")
check_response "$response" "Successfully left the group" "Leave Group" || all_passed=false

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