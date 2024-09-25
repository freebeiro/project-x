# 12. Wireframes and User Interface Guidelines

This section provides detailed descriptions of key wireframes for the main screens of the SW Dev Group Dating App. Developers should use these descriptions to create visual mockups and implement the user interface.

### 12.1 Main Navigation
The app will use a bottom navigation bar with five main sections:
1. Home
2. Groups
3. Events
4. Chat
5. Profile

### 12.2 Home Screen
- Header: App logo on the left, notification bell icon on the right
- Welcome message: "Hello, [User Name]"
- Upcoming Events section:
  - Horizontal scrollable list of event cards
  - Each card shows event image, title, date, and attending group
- My Groups section:
  - Horizontal scrollable list of group avatars
  - "+" button at the end to create or join new groups
- Nearby Events section:
  - Vertical list of nearby events
  - Each item shows event image, title, date, distance, and a "Join" button

### 12.3 Group Screen
- Search bar at the top
- Toggle between "My Groups" and "Discover" tabs
- My Groups tab:
  - Grid view of group cards
  - Each card shows group image, name, and member count
  - "+" card to create a new group
- Discover tab:
  - List of suggested groups based on user interests
  - Each item shows group image, name, member count, and "Join" button

### 12.4 Group Detail Screen
- Group cover photo at the top
- Group name and description
- Member count and "See All" button
- Upcoming Events section:
  - Horizontal scrollable list of event cards
- Recent Posts section:
  - Vertical list of recent group posts
  - Each post shows user avatar, name, post content, and image (if any)
- "Create Post" floating action button

### 12.5 Events Screen
- Search bar at the top
- Toggle between "My Events" and "Discover" tabs
- Calendar view at the top, showing events on each date
- List of events below the calendar
  - Each event item shows event image, title, date, time, location, and attending groups

### 12.6 Event Detail Screen
- Event cover photo at the top
- Event title, date, time, and location
- "Attend" button (changes to "Attending" if user is attending)
- Event description
- Attending Groups section:
  - Horizontal scrollable list of group avatars
- Discussion Board:
  - List of comments/posts related to the event
  - Text input at the bottom to add a new comment

### 12.7 Chat Screen
- List of active chats
  - Each chat item shows group/event image, name, last message preview, and timestamp
- Search bar at the top to find specific chats

### 12.8 Chat Detail Screen
- Chat header with group/event name and participant count
- Message thread occupying most of the screen
  - Each message shows sender's avatar, name, message content, and timestamp
- Text input at the bottom with attachment and send buttons

### 12.9 Profile Screen
- User's profile picture at the top
- User's name and username
- Edit Profile button
- Stats section showing number of groups, events attended, and connections
- My Interests section:
  - Tags representing user's interests
- Settings button at the bottom

### 12.10 General UI Guidelines
- Use a clean, modern design with ample white space
- Stick to the color palette defined in section 5.2
- Use card-based design for lists of groups, events, and posts
- Implement pull-to-refresh for content updates
- Use skeleton screens for loading states
- Implement smooth transitions between screens
- Ensure all interactive elements have clear hover and active states
- Use system fonts or a clean sans-serif font family
- Ensure sufficient color contrast for readability
- Design with accessibility in mind, supporting dynamic type sizes

Developers should create high-fidelity mockups based on these wireframe descriptions, ensuring consistency across all screens and adherence to the app's overall design philosophy.

