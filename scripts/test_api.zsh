#!/bin/zsh

# Change to the Rails root directory
cd "$(dirname "$0")/.." || exit

# Kill any existing Rails server on port 3005
lsof -ti:3005 | xargs kill -9 2>/dev/null || true

# Remove any stale pid file
rm -f tmp/pids/server.pid

# Load environment variables from .env if it exists AND we are NOT in CI
if [ -f .env ] && [ -z "$CI" ]; then
  echo "Loading environment variables from .env file (local)"
  # Use a safer method to load .env that handles values with spaces/special chars
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^[^#]*= ]]; then
      export "$line"
    fi
  done < .env
fi

# --- CI Fixes ---
# Ensure RAILS_ENV is set to test for this script's context
export RAILS_ENV=test
echo "RAILS_ENV set to $RAILS_ENV"

# Setup test database BEFORE starting server
echo "Setting up test database..."
bundle exec rails db:drop RAILS_ENV=test || echo "Failed to drop DB (might not exist)" # Allow failure if DB doesn't exist
bundle exec rails db:create RAILS_ENV=test
bundle exec rails db:migrate RAILS_ENV=test
echo "Database setup complete."

# Start the Rails server in the background using the test environment
echo "Starting Rails server in test environment on port 3005..."
bundle exec rails s -p 3005 -e test -d
# --- End CI Fixes ---

# Wait for the server to start and become responsive
echo "Waiting for server..."
max_wait=30 # Maximum wait time in seconds
interval=2  # Check interval
elapsed=0
server_ready=false
while [ $elapsed -lt $max_wait ]; do
  # Check if server process exists (optional, might be tricky with -d)
  # pgrep -f 'rails s -p 3005 -e test' > /dev/null || { echo "Server process not found!"; break; }

  # Check if server responds to a simple request
  curl -s --head http://localhost:3005/users/sign_in > /dev/null # Use a known path
  if [ $? -eq 0 ]; then
    echo "Server is up!"
    server_ready=true
    break
  fi
  echo "Server not responding yet..."
  sleep $interval
  elapsed=$((elapsed + interval))
done

if [ "$server_ready" = false ]; then
  echo "${RED}Server failed to start or become responsive within $max_wait seconds.${NC}"
  # Optionally try to get logs
  echo "Attempting to retrieve server logs:"
  cat tmp/pids/server.pid | xargs -I {} ps {} || echo "Could not get process info."
  tail log/test.log || echo "Could not read test.log"
  exit 1
fi
# --- End Health Check ---

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

# Function to check HTTP status code
check_status_code() {
    local response_code=$1
    local expected_code=$2
    local test_name=$3

    if [[ "$response_code" -eq "$expected_code" ]]; then
        echo "${GREEN}Pass: $test_name (Status Code: $response_code)${NC}"
        return 0
    else
        echo "${RED}Fail: $test_name${NC}"
        echo "Expected Status Code: $expected_code"
        echo "Got Status Code: $response_code"
        return 1
    fi
}

# Variable to track overall success
all_passed=true

# Removed redundant DB setup, rspec, rubocop calls - handled in CI steps

# User Registration
echo "\nTesting User Registration:"
response=$(curl -s -X POST "${BASE_URL}/users" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "testuser@example.com",
      "password": "password123",
      "password_confirmation": "password123",
      "date_of_birth": "2000-01-01",
      "profile_attributes": {
        "first_name": "Test",
        "last_name": "User",
        "age": 23,
        "username": "testuser",
        "description": "A test user",
        "occupation": "Tester"
      }
    }
  }')
check_response "$response" "Signed up successfully." "User Registration" || all_passed=false

# User Registration (existing user) - Profile data not needed here as it fails on email uniqueness
echo "\nTesting User Registration (existing user):"
response=$(curl -s -X POST "${BASE_URL}/users" \
  -H "Content-Type: application/json" \
  -d '{"user": {"email": "testuser@example.com","password": "password123","password_confirmation": "password123","date_of_birth": "2000-01-01"}}' )
check_response "$response" "User couldn't be created successfully. Email has already been taken" "User Registration (existing user)" || all_passed=false

# User Registration (underage)
echo "\nTesting User Registration (underage):"
response=$(curl -s -X POST "${BASE_URL}/users" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "underage@example.com",
      "password": "password123",
      "password_confirmation": "password123",
      "date_of_birth": "2010-10-05"
    }
  }')
check_response "$response" "Date of birth You must be at least 16 years old" "User Registration (underage)" || all_passed=false
status_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "${BASE_URL}/users" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "underage@example.com",
      "password": "password123",
      "password_confirmation": "password123",
      "date_of_birth": "2010-10-05"
    }
  }')
check_status_code "$status_code" 422 "User Registration (underage) Status Code" || all_passed=false


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
main_user_id=$(echo $response | jq -r '.id')

# Create a friend user
echo "\nCreating a friend user:"
response=$(curl -s -X POST "${BASE_URL}/users" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "friend@example.com",
      "password": "password123",
      "password_confirmation": "password123",
      "date_of_birth": "2000-01-01",
      "profile_attributes": {
        "first_name": "Friend",
        "last_name": "User",
        "age": 23,
        "username": "frienduser",
        "description": "A friend user",
        "occupation": "Friend"
      }
    }
  }')
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
  -d '{
    "user": {
      "email": "nonfriend@example.com",
      "password": "password123",
      "password_confirmation": "password123",
      "date_of_birth": "2000-01-01",
      "profile_attributes": {
        "first_name": "NonFriend",
        "last_name": "User",
        "age": 23,
        "username": "nonfrienduser",
        "description": "A non-friend user",
        "occupation": "NonFriend"
      }
    }
  }')
check_response "$response" "Signed up successfully." "Non-Friend User Registration" || all_passed=false

# Extract non-friend user ID (Corrected path)
non_friend_user_id=$(echo "$response" | jq -r '.data.id')
if [[ -z "$non_friend_user_id" || "$non_friend_user_id" == "null" ]]; then
  echo "${RED}Fail: Could not extract non_friend_user_id${NC}"
  all_passed=false
fi

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

# Extract group_id from the response (assuming nested under 'data' like login)
group_id=$(echo "$response" | jq -r '.data.id') # Changed extraction to .data.id
if [[ -z "$group_id" || "$group_id" == "null" ]]; then
  echo "${RED}Fail: Could not extract group_id${NC}"
  all_passed=false
fi

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

echo "\n\n=== Testing Event System (Now Nested Under Groups) ==="

# Need a group for event tests
echo "\nCreating group for event tests:"
response=$(curl -s -X POST "${BASE_URL}/groups" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json" \
  -d '{"group": {"name": "Event Test Group", "description": "Group for event tests", "privacy": "public", "member_limit": 10}}')
check_response "$response" "Event Test Group" "Create Event Group" || all_passed=false
event_test_group_id=$(echo "$response" | jq -r '.data.id') # Assuming .data.id based on previous fix attempt
if [[ -z "$event_test_group_id" || "$event_test_group_id" == "null" ]]; then
  event_test_group_id=$(echo "$response" | jq -r '.id') # Fallback
  if [[ -z "$event_test_group_id" || "$event_test_group_id" == "null" ]]; then
    echo "${RED}Fail: Could not extract event_test_group_id${NC}"
    all_passed=false
  fi
fi

# Create Event (Nested)
echo "\nCreating event (nested under group $event_test_group_id):"
response=$(curl -s -X POST "${BASE_URL}/groups/${event_test_group_id}/events" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $token" \
  -H "Accept: application/json" \
  -H "Accept: application/json" \
  -d '{
    "event": {
      "name": "Developer Meetup",
      "description": "Monthly Ruby/Rails meetup",
      "location": "Virtual",
      "start_time": "2025-04-15T18:00:00",
      "end_time": "2025-04-15T20:00:00",
      "capacity": 50
    }
  }')
check_response "$response" "Developer Meetup" "Create Event" || all_passed=false

# Extract event ID (assuming direct object in response)
event_id=$(echo "$response" | jq -r '.id')
if [[ -z "$event_id" || "$event_id" == "null" ]]; then # Corrected syntax [[ ... ]]
  echo "${RED}Fail: Could not extract event_id${NC}"
  all_passed=false
fi

# List Events (Note: Top-level GET /events might still exist or need adjustment depending on desired API design)
# Assuming we test listing events scoped to the group for now
echo "\nListing events (for group $event_test_group_id):"
response=$(curl -s -X GET "${BASE_URL}/groups/${event_test_group_id}/events" \
  -H "Authorization: Bearer $token" \
  -H "Accept: application/json")
check_response "$response" "Developer Meetup" "List Group Events" || all_passed=false

# Create Participation & Extract ID (Nested)
echo "\nJoining event:"
response=$(curl -s -X POST "${BASE_URL}/groups/${event_test_group_id}/events/${event_id}/participations" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json")
# Assuming successful join returns the participation object with status
check_response "$response" "\"status\":\"attending\"" "Join Event" || all_passed=false
participation_id=$(echo "$response" | jq -r '.id') # Use .id if response is just the object
if [[ -z "$participation_id" || "$participation_id" == "null" ]]; then # Corrected syntax [[ ... ]]
  echo "${RED}Fail: Could not extract participation_id${NC}"
  all_passed=false
fi

# List Participations (Nested)
echo "\nEvent participations:"
response=$(curl -s -X GET "${BASE_URL}/groups/${event_test_group_id}/events/${event_id}/participations" \
  -H "Authorization: Bearer $token" \
  -H "Accept: application/json")
check_response "$response" "\"user_id\":$main_user_id" "List Participations (Check own participation)" || all_passed=false

# Show Specific Event (Nested)
echo "\nShowing specific event:"
response=$(curl -s -X GET "${BASE_URL}/groups/${event_test_group_id}/events/${event_id}" \
  -H "Authorization: Bearer $token" \
  -H "Accept: application/json")
check_response "$response" "\"id\":$event_id" "Show Event" || all_passed=false

# Update Event (Happy Path - Nested)
echo "\nUpdating event:"
response=$(curl -s -X PUT "${BASE_URL}/groups/${event_test_group_id}/events/${event_id}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $token" \
  -H "Accept: application/json" \
  -H "Accept: application/json" \
  -d '{ "event": { "name": "Updated Developer Meetup" } }')
check_response "$response" "Updated Developer Meetup" "Update Event (Happy Path)" || all_passed=false

# Update Event (Unauthorized by friend - Nested)
echo "\nUpdating event (Unauthorized):"
response=$(curl -s -X PUT "${BASE_URL}/groups/${event_test_group_id}/events/${event_id}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $friend_token" \
  -H "Accept: application/json" \
  -H "Accept: application/json" \
  -d '{ "event": { "name": "Unauthorized Update Attempt" } }')
check_response "$response" "Not authorized" "Update Event (Unauthorized)" || all_passed=false

# Join Event Again (should fail - Nested)
echo "\nJoining event again (should fail):"
response=$(curl -s -X POST "${BASE_URL}/groups/${event_test_group_id}/events/${event_id}/participations" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json")
check_response "$response" "is already participating in this event" "Join Event Again" || all_passed=false # Updated expected message

# Leave Event (Happy Path - Nested)
echo "\nLeaving event:"
status_code=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "${BASE_URL}/groups/${event_test_group_id}/events/${event_id}/participations/${participation_id}" \
  -H "Authorization: Bearer $token")
check_status_code "$status_code" 204 "Leave Event (Happy Path)" || all_passed=false

# Leave Event (Unauthorized by friend - Nested)
echo "\nLeaving event (Unauthorized):"
status_code=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "${BASE_URL}/groups/${event_test_group_id}/events/${event_id}/participations/${participation_id}" \
  -H "Authorization: Bearer $friend_token")
check_status_code "$status_code" 404 "Leave Event (Unauthorized)" || all_passed=false # Expect 404 as participation won't be found for friend

# Leave Event (Non-existent participation - Nested)
echo "\nLeaving event (Non-existent):"
status_code=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "${BASE_URL}/groups/${event_test_group_id}/events/${event_id}/participations/99999" \
  -H "Authorization: Bearer $token")
check_status_code "$status_code" 404 "Leave Event (Non-existent)" || all_passed=false

# Test Event Capacity (Small Event - Nested)
echo "\nTesting Event Capacity (Small Event):"
# Create a small event (capacity 1 - Nested)
response=$(curl -s -X POST "${BASE_URL}/groups/${event_test_group_id}/events" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $token" \
  -H "Accept: application/json" \
  -H "Accept: application/json" \
  -d '{
    "event": {
      "name": "Small Event",
      "description": "Limited capacity event",
      "location": "Virtual",
      "start_time": "2025-04-15T18:00:00",
      "end_time": "2025-04-15T20:00:00",
      "capacity": 1
    }
  }')
check_response "$response" "Small Event" "Create Small Event" || all_passed=false
small_event_id=$(echo "$response" | jq -r '.id') # Corrected extraction
if [[ -z "$small_event_id" || "$small_event_id" == "null" ]]; then # Corrected syntax [[ ... ]]
  echo "${RED}Fail: Could not extract small_event_id${NC}"
  all_passed=false
fi

# First participant joins successfully (Nested)
echo "\nFirst participant joins:"
response=$(curl -s -X POST "${BASE_URL}/groups/${event_test_group_id}/events/${small_event_id}/participations" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json")
check_response "$response" "\"status\":\"attending\"" "First Join" || all_passed=false # Updated check to look for status in JSON

# Second participant (friend user) attempts to join (should fail - Nested)
echo "\nSecond participant attempts to join small event (should fail):"
response=$(curl -s -X POST "${BASE_URL}/groups/${event_test_group_id}/events/${small_event_id}/participations" \
  -H "Authorization: Bearer $friend_token" \
  -H "Content-Type: application/json")
check_response "$response" "Event is at capacity" "Capacity Check" || all_passed=false
status_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "${BASE_URL}/groups/${event_test_group_id}/events/${small_event_id}/participations" \
  -H "Authorization: Bearer $friend_token" \
  -H "Content-Type: application/json")
check_status_code "$status_code" 422 "Capacity Check Status Code" || all_passed=false

# Delete Event (Unauthorized by friend - Nested)
echo "\nDeleting event (Unauthorized):"
status_code=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "${BASE_URL}/groups/${event_test_group_id}/events/${event_id}" \
  -H "Authorization: Bearer $friend_token")
check_status_code "$status_code" 403 "Delete Event (Unauthorized)" || all_passed=false

# Delete Event (Happy Path - Nested)
echo "\nDeleting event:"
status_code=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "${BASE_URL}/groups/${event_test_group_id}/events/${event_id}" \
  -H "Authorization: Bearer $token")
check_status_code "$status_code" 204 "Delete Event (Happy Path)" || all_passed=false

# Show Event (After Delete - should fail - Nested)
echo "\nShowing deleted event (should fail):"
status_code=$(curl -s -o /dev/null -w "%{http_code}" -X GET "${BASE_URL}/groups/${event_test_group_id}/events/${event_id}" \
  -H "Authorization: Bearer $token" \
  -H "Accept: application/json")
check_status_code "$status_code" 404 "Show Deleted Event" || all_passed=false

echo "\n=== Event System Testing Complete ==="


echo "\n\n=== Testing Chat System (HTTP Endpoint) ==="

# Need a group and event where the main user is authorized
# Re-create group and event for clarity in this section
echo "\nCreating group for chat tests:"
response=$(curl -s -X POST "${BASE_URL}/groups" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json" \
  -d '{"group": {"name": "Chat Test Group", "description": "Group for chat tests", "privacy": "public", "member_limit": 10}}')
check_response "$response" "Chat Test Group" "Create Chat Group" || all_passed=false
chat_group_id=$(echo "$response" | jq -r '.data.id') # Assuming .data.id based on previous fix attempt
if [[ -z "$chat_group_id" || "$chat_group_id" == "null" ]]; then
  # Fallback if .data.id was wrong for groups
  chat_group_id=$(echo "$response" | jq -r '.id')
  if [[ -z "$chat_group_id" || "$chat_group_id" == "null" ]]; then
    echo "${RED}Fail: Could not extract chat_group_id${NC}"
    all_passed=false
  fi
fi

echo "\nCreating event for chat tests (associated with group $chat_group_id):"
response=$(curl -s -X POST "${BASE_URL}/groups/${chat_group_id}/events" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $token" \
  -H "Accept: application/json" \
  -H "Accept: application/json" \
  -d "{
    \"event\": {
      \"name\": \"Chat Test Event\",
      \"description\": \"Event for chat tests\",
      \"location\": \"Virtual\",
      \"start_time\": \"2025-04-15T18:00:00\",
      \"end_time\": \"2025-04-15T20:00:00\",
      \"capacity\": 10,
      \"group_id\": $chat_group_id
    }
  }")
check_response "$response" "Chat Test Event" "Create Chat Event" || all_passed=false
chat_event_id=$(echo "$response" | jq -r '.id') # Assuming direct .id based on previous event creation
if [[ -z "$chat_event_id" || "$chat_event_id" == "null" ]]; then
  echo "${RED}Fail: Could not extract chat_event_id${NC}"
  all_passed=false
fi

# User needs to join group and event to be authorized for chat
echo "\nJoining chat group:"
response=$(curl -s -X POST "${BASE_URL}/groups/${chat_group_id}/group_membership" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json")
check_response "$response" "Successfully joined the group" "Join Chat Group" || all_passed=false

echo "\nJoining chat event:"
response=$(curl -s -X POST "${BASE_URL}/groups/${chat_group_id}/events/${chat_event_id}/participations" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json")
check_response "$response" "\"status\":\"attending\"" "Join Chat Event" || all_passed=false

# Post a valid message
echo "\nPosting a valid message:"
response=$(curl -s -X POST "${BASE_URL}/groups/${chat_group_id}/events/${chat_event_id}/api/v1/messages" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json" \
  -d '{"message": {"content": "Hello chat!"}}')
check_response "$response" "Hello chat!" "Post Valid Message" || all_passed=false
message_id=$(echo "$response" | jq -r '.id')
if [[ -z "$message_id" || "$message_id" == "null" ]]; then
  echo "${RED}Fail: Could not extract message_id${NC}"
  all_passed=false
fi

# Post a blank message (should fail)
echo "\nPosting a blank message (should fail):"
response=$(curl -s -X POST "${BASE_URL}/groups/${chat_group_id}/events/${chat_event_id}/api/v1/messages" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json" \
  -d '{"message": {"content": ""}}')
check_response "$response" "Content can't be blank" "Post Blank Message" || all_passed=false
status_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "${BASE_URL}/groups/${chat_group_id}/events/${chat_event_id}/api/v1/messages" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json" \
  -d '{"message": {"content": ""}}')
check_status_code "$status_code" 422 "Post Blank Message Status Code" || all_passed=false

# List messages
echo "\nListing messages:"
response=$(curl -s -X GET "${BASE_URL}/groups/${chat_group_id}/events/${chat_event_id}/api/v1/messages" \
  -H "Authorization: Bearer $token")
check_response "$response" "Hello chat!" "List Messages" || all_passed=false
# Check if the response is an array and contains the message id
if [[ $(echo "$response" | jq -r 'if type=="array" then .[] | select(.id=='$message_id') | .id else empty end') == $message_id ]]; then
    echo "${GREEN}Pass: List Messages contains posted message${NC}"
else
    echo "${RED}Fail: List Messages does not contain posted message${NC}"
    echo "Got: $response"
    all_passed=false
fi

# Attempt to post message when unauthorized (using friend token)
echo "\nPosting message (unauthorized):"
response=$(curl -s -X POST "${BASE_URL}/groups/${chat_group_id}/events/${chat_event_id}/api/v1/messages" \
  -H "Authorization: Bearer $friend_token" \
  -H "Content-Type: application/json" \
  -d '{"message": {"content": "Unauthorized attempt"}}')
check_response "$response" "Not authorized to access this chat" "Post Message Unauthorized" || all_passed=false
status_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "${BASE_URL}/groups/${chat_group_id}/events/${chat_event_id}/api/v1/messages" \
  -H "Authorization: Bearer $friend_token" \
  -H "Content-Type: application/json" \
  -d '{"message": {"content": "Unauthorized attempt"}}')
check_status_code "$status_code" 403 "Post Message Unauthorized Status Code" || all_passed=false

# Attempt to list messages when unauthorized (using friend token)
echo "\nListing messages (unauthorized):"
response=$(curl -s -X GET "${BASE_URL}/groups/${chat_group_id}/events/${chat_event_id}/api/v1/messages" \
  -H "Authorization: Bearer $friend_token")
check_response "$response" "Not authorized to access this chat" "List Messages Unauthorized" || all_passed=false
status_code=$(curl -s -o /dev/null -w "%{http_code}" -X GET "${BASE_URL}/groups/${chat_group_id}/events/${chat_event_id}/api/v1/messages" \
  -H "Authorization: Bearer $friend_token")
check_status_code "$status_code" 403 "List Messages Unauthorized Status Code" || all_passed=false

echo "\n=== Chat System Testing Complete ==="


echo "\n\n=== Testing Group Posts (HTTP Endpoint) ==="

# Use the same group/event as chat tests for simplicity
chat_group_id=$chat_group_id # Already defined
chat_event_id=$chat_event_id # Already defined

# Ensure main user is still authorized (joined group/event earlier)

# Post a valid text-only post
echo "\nPosting a valid text post:"
post_content="This is a test post for event $chat_event_id in group $chat_group_id"
response=$(curl -s -X POST "${BASE_URL}/groups/${chat_group_id}/events/${chat_event_id}/api/v1/posts" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json" \
  -d "{\"post\": {\"content\": \"$post_content\"}}")
check_response "$response" "$post_content" "Post Valid Text Post" || all_passed=false
post_id=$(echo "$response" | jq -r '.id')
if [[ -z "$post_id" || "$post_id" == "null" ]]; then
  echo "${RED}Fail: Could not extract post_id${NC}"
  all_passed=false
fi

# Post without content or image (should fail)
echo "\nPosting a blank post (should fail):"
response=$(curl -s -X POST "${BASE_URL}/groups/${chat_group_id}/events/${chat_event_id}/api/v1/posts" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json" \
  -d '{"post": {}}') # Sending empty post object
check_response "$response" "Content can't be blank" "Post Blank Post" || all_passed=false # Assumes validation message
status_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "${BASE_URL}/groups/${chat_group_id}/events/${chat_event_id}/api/v1/posts" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json" \
  -d '{"post": {}}')
check_status_code "$status_code" 422 "Post Blank Post Status Code" || all_passed=false

# List posts for the event
echo "\nListing posts:"
response=$(curl -s -X GET "${BASE_URL}/groups/${chat_group_id}/events/${chat_event_id}/api/v1/posts" \
  -H "Authorization: Bearer $token")
check_response "$response" "$post_content" "List Posts" || all_passed=false
# Check if the response is an array and contains the post id
if [[ $(echo "$response" | jq -r 'if type=="array" then .[] | select(.id=='$post_id') | .id else empty end') == $post_id ]]; then
    echo "${GREEN}Pass: List Posts contains posted post${NC}"
else
    echo "${RED}Fail: List Posts does not contain posted post${NC}"
    echo "Got: $response"
    all_passed=false
fi

# Attempt to post when unauthorized (using friend token)
echo "\nPosting post (unauthorized):"
response=$(curl -s -X POST "${BASE_URL}/groups/${chat_group_id}/events/${chat_event_id}/api/v1/posts" \
  -H "Authorization: Bearer $friend_token" \
  -H "Content-Type: application/json" \
  -d '{"post": {"content": "Unauthorized post attempt"}}')
check_response "$response" "Not authorized to access posts" "Post Post Unauthorized" || all_passed=false
status_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "${BASE_URL}/groups/${chat_group_id}/events/${chat_event_id}/api/v1/posts" \
  -H "Authorization: Bearer $friend_token" \
  -H "Content-Type: application/json" \
  -d '{"post": {"content": "Unauthorized post attempt"}}')
check_status_code "$status_code" 403 "Post Post Unauthorized Status Code" || all_passed=false

# Attempt to list posts when unauthorized (using friend token)
echo "\nListing posts (unauthorized):"
response=$(curl -s -X GET "${BASE_URL}/groups/${chat_group_id}/events/${chat_event_id}/api/v1/posts" \
  -H "Authorization: Bearer $friend_token")
check_response "$response" "Not authorized to access posts" "List Posts Unauthorized" || all_passed=false
status_code=$(curl -s -o /dev/null -w "%{http_code}" -X GET "${BASE_URL}/groups/${chat_group_id}/events/${chat_event_id}/api/v1/posts" \
  -H "Authorization: Bearer $friend_token")
check_status_code "$status_code" 403 "List Posts Unauthorized Status Code" || all_passed=false


echo "\n=== Group Posts Testing Complete ==="


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
    echo "\n${RED}Some API tests failed. Please check the output above.${NC}"
    # Don't exit immediately on API failure, run other checks first
fi

# Stop the background server before running checks
echo "\nStopping background test server..."
# Find the PID from the file and kill the process
if [ -f tmp/pids/server.pid ]; then
  pid=$(cat tmp/pids/server.pid)
  if ps -p $pid > /dev/null; then
     echo "Killing server process $pid..."
     kill -9 $pid || echo "Failed to kill process $pid (maybe already stopped?)"
     # Wait a moment for the process to terminate
     sleep 1
  else
     echo "Server process $pid not found."
  fi
  rm -f tmp/pids/server.pid
else
  echo "PID file not found, server might not have started correctly or was already stopped."
fi

# Run RSpec check
echo "\nRunning RSpec..."
bundle exec rspec
rspec_exit_code=$? # Capture RSpec exit code

if [ "$rspec_exit_code" -ne 0 ]; then
    echo "${RED}RSpec tests failed.${NC}"
    all_passed=false # Mark overall status as failed if RSpec fails
else
    echo "${GREEN}RSpec tests passed.${NC}"
fi

# Run RuboCop check
echo "\nRunning RuboCop..."
bundle exec rubocop
rubocop_exit_code=$? # Capture RuboCop exit code

if [ "$rubocop_exit_code" -ne 0 ]; then
    echo "${RED}RuboCop found offenses.${NC}"
    all_passed=false # Mark overall status as failed if RuboCop fails
else
    echo "${GREEN}RuboCop passed.${NC}"
fi

# Summary report
echo "\n=== Test Results ==="

# RSpec results (Now checked earlier and affects all_passed)
if [ "$rspec_exit_code" -eq 0 ]; then
    echo "RSpec: ${GREEN}Passed${NC}"
else
    # Attempt to extract summary even on failure
    rspec_summary=$(bundle exec rspec --format documentation | grep -E '[0-9]+ examples?, [0-9]+ failures?') # Try getting summary
    echo "RSpec: ${RED}Failed (Exit Code: $rspec_exit_code)${NC} ${rspec_summary}"
fi

# Coverage - Ensure file exists before reading
# Note: Coverage is generated by the RSpec run above
coverage="N/A"
if [ -f coverage/.last_run.json ]; then
  coverage_raw=$(awk -F':' '/"line":/ {print $2}' coverage/.last_run.json | tr -d ' ,')
  # Check if coverage_raw is a number
  if [[ "$coverage_raw" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    coverage="${coverage_raw}%"
  fi
fi
echo "Coverage: $coverage" # Note: Coverage is from separate RSpec run

# RuboCop results (Now checked earlier and affects all_passed)
if [ "$rubocop_exit_code" -eq 0 ]; then
    echo "RuboCop: ${GREEN}Passed${NC}"
else
    echo "RuboCop: ${RED}Failed (Exit Code: $rubocop_exit_code)${NC}"
fi

# Overall result check (now includes RSpec and RuboCop status via all_passed)
if $all_passed; then
    echo "\n${GREEN}All API tests, RSpec, and RuboCop passed successfully!${NC}"
    exit 0 # Success
else
    echo "\n${RED}One or more checks (API, RSpec, RuboCop) failed. Please review the output.${NC}"
    exit 1 # Failure
fi
