# 11. API Specifications

This section outlines the key API endpoints for the SW Dev Group Dating App. All endpoints should be prefixed with `/api/v1/` to allow for future versioning.

### 11.1 Authentication

- POST /auth/register
  - Request: { email, password, name, dateOfBirth }
  - Response: { userId, token }

- POST /auth/login
  - Request: { email, password }
  - Response: { userId, token }

- POST /auth/logout
  - Request: { token }
  - Response: { success: true }

### 11.2 User Management

- GET /users/{userId}
  - Response: { userId, name, email, profilePicture, bio, interests }

- PUT /users/{userId}
  - Request: { name, email, profilePicture, bio, interests }
  - Response: { userId, name, email, profilePicture, bio, interests }

- GET /users/{userId}/groups
  - Response: [{ groupId, name, description }, ...]

### 11.3 Group Management

- POST /groups
  - Request: { name, description, privacy, memberLimit }
  - Response: { groupId, name, description, privacy, memberLimit }

- GET /groups/{groupId}
  - Response: { groupId, name, description, privacy, memberLimit, members: [userId, ...] }

- PUT /groups/{groupId}
  - Request: { name, description, privacy, memberLimit }
  - Response: { groupId, name, description, privacy, memberLimit }

- POST /groups/{groupId}/members
  - Request: { userId }
  - Response: { success: true }

- DELETE /groups/{groupId}/members/{userId}
  - Response: { success: true }

### 11.4 Event System

- POST /events
  - Request: { title, description, date, time, location, capacity, groupIds: [groupId, ...] }
  - Response: { eventId, title, description, date, time, location, capacity, groupIds: [groupId, ...] }

- GET /events/{eventId}
  - Response: { eventId, title, description, date, time, location, capacity, attendees: [userId, ...], waitlist: [userId, ...] }

- PUT /events/{eventId}
  - Request: { title, description, date, time, location, capacity }
  - Response: { eventId, title, description, date, time, location, capacity }

- POST /events/{eventId}/attend
  - Request: { userId }
  - Response: { success: true, status: "attending" | "waitlisted" }

- DELETE /events/{eventId}/attend
  - Request: { userId }
  - Response: { success: true }

### 11.5 Chat Functionality

- GET /chats/{groupId}
  - Query params: { limit, before }
  - Response: [{ messageId, userId, content, timestamp }, ...]

- POST /chats/{groupId}
  - Request: { userId, content }
  - Response: { messageId, userId, content, timestamp }

### 11.6 Content Management

- POST /posts
  - Request: { groupId, eventId, content, images: [base64EncodedImage, ...] }
  - Response: { postId, groupId, eventId, content, images: [imageUrl, ...], timestamp }

- GET /posts/{groupId}
  - Query params: { limit, before }
  - Response: [{ postId, userId, content, images: [imageUrl, ...], timestamp }, ...]

- POST /posts/{postId}/comments
  - Request: { userId, content }
  - Response: { commentId, userId, content, timestamp }

### 11.7 Event Organizer Features

- GET /organizer/events
  - Query params: { userId, startDate, endDate }
  - Response: [{ eventId, title, date, time, location, attendeeCount }, ...]

- GET /organizer/events/{eventId}/analytics
  - Response: { attendeeCount, ageDistribution, genderDistribution }

All endpoints should return appropriate HTTP status codes (200 for success, 400 for bad requests, 401 for unauthorized, 403 for forbidden, 404 for not found, etc.). Error responses should include a message explaining the error.

