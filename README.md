# SW Dev Group Dating App (Backend)

Welcome to the backend repository for the SW Dev Group Dating App, a Ruby on Rails application designed to facilitate group dating and social interactions at events. This backend powers user management, group creation, event systems, real-time chat, and content sharing, all while ensuring scalability, security, and compliance with regulations like GDPR, CCPA, and COPPA.

## Table of Contents

- [Project Overview](#project-overview)
- [System Architecture](#system-architecture)
- [Authentication Flow](#authentication-flow)
- [Core Features](#core-features)
- [Getting Started](#getting-started)
- [API Documentation](#api-documentation)
- [Development Guidelines](#development-guidelines)
- [Testing](#testing)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [License](#license)

## Project Overview

- **Purpose**: A mobile app backend for group dating and event-based social interactions.
- **Target Audience**: Users aged 16+ seeking safe, engaging group experiences.
- **Business Goals**: 
  - Facilitate meaningful connections through group settings
  - Provide a safe, moderated environment for social interactions
  - Enable event-based engagement and content sharing

## System Architecture

The application follows a RESTful API architecture with the following components:

### Backend Components
- **API Layer**: Rails controllers that handle HTTP requests and responses
- **Service Layer**: Business logic encapsulated in service objects
- **Data Layer**: ActiveRecord models for database interactions
- **Authentication**: JWT-based token authentication system

### Database Schema
- Users and Profiles
- Groups and Group Memberships
- Friendships with status tracking
- (Planned) Events and Attendees
- (Planned) Messages and Content Sharing

### Third-party Integrations
- (Planned) Geolocation services
- (Planned) Push notification services
- (Planned) Media storage and processing

## Authentication Flow

The application uses JWT (JSON Web Token) for stateless authentication:

1. **Registration**: User creates an account with email, password, and date of birth
2. **Login**: User provides credentials and receives a JWT token
3. **Authentication**: Subsequent requests include the JWT token in the Authorization header
4. **Token Validation**: System validates the token before processing requests
5. **Logout**: Token is blacklisted upon logout

Security measures include:
- Token expiration (24 hours)
- Token blacklisting
- HTTPS for all communications
- Secure password hashing with Devise

## Core Features

- **User Management**:
  - Registration and authentication
  - Profile creation and customization
  - User search and discovery
  
- **Social Connections**:
  - Friendship requests and management
  - User profile visibility controls
  
- **Group System**:
  - Creation of groups (2-20 members)
  - Group membership management
  - Privacy settings for groups
  
- **(Planned) Event System**:
  - Event creation and discovery
  - Event joining and leaving
  - Geolocation-based check-ins
  
- **(Planned) Communication**:
  - Real-time group chat during events
  - Content sharing tied to events and groups

## Getting Started

### Prerequisites

- Ruby (version X.X.X) - Check `.ruby-version` for the exact version.
- Rails (version X.X.X) - See `Gemfile`.
- PostgreSQL (or your database of choice).
- `curl` and `jq` for runtime testing.
- `zsh` (optional, for running the test script).

### Installation

1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   cd sw-dev-group-dating-app-backend
   ```

2. **Install Dependencies**:
   ```bash
   bundle install
   ```

3. **Set Up Database**:
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed  # Optional, for development data
   ```

4. **Environment Variables**:
   Create a `.env` file based on `.env.example` and configure:
   - Database credentials
   - JWT secret key (required for authentication)
     - Generate a secure key with `rails secret`
     - Set as `JWT_SECRET_KEY` in your `.env` file
   - Other service API keys

5. **Run the Server**:
   ```bash
   rails server
   ```

### Running Tests
```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/controllers/users/sessions_controller_spec.rb

# Run the API test script
chmod +x scripts/test_api.zsh && ./scripts/test_api.zsh
```

## API Documentation

### Authentication Endpoints

- **POST /api/v1/users/registration** - Register a new user
- **POST /api/v1/users/login** - User login
- **DELETE /api/v1/users/logout** - User logout

### User Endpoints

- **GET /api/v1/users/search** - Search for users
- **GET /api/v1/profiles/:id** - View a user profile
- **PUT /api/v1/profiles/:id** - Update user profile

### Group Endpoints

- **POST /api/v1/groups** - Create a group
- **GET /api/v1/groups/:id** - View group details
- **PUT /api/v1/groups/:id** - Update group details
- **DELETE /api/v1/groups/:id** - Delete a group

### Group Membership Endpoints

- **POST /api/v1/group_memberships** - Join a group
- **DELETE /api/v1/group_memberships/:id** - Leave a group

### Friendship Endpoints

- **POST /api/v1/friendships** - Send friendship request
- **PUT /api/v1/friendships/:id/accept** - Accept a friendship request
- **PUT /api/v1/friendships/:id/decline** - Decline a friendship request
- **DELETE /api/v1/friendships/:id** - Remove a friendship

## Development Guidelines

### Code Style

- Follow the Ruby Style Guide
- Use RuboCop for code linting
- Maintain consistent naming conventions

### Git Workflow

1. Create feature branches from `main`
2. Use descriptive commit messages
3. Submit pull requests for review
4. Squash and merge after approval

### Architecture Principles

- Follow SOLID principles
- Use service objects for complex business logic
- Keep controllers thin, models fat
- Write comprehensive tests

## AI-Assisted Development Workflow

This project leverages an AI assistant (Cline, integrated within VS Code) to enhance the development process. This approach aims to improve efficiency, code quality, and adherence to best practices.

### Our Approach

The collaboration with the AI assistant follows an iterative cycle:

1.  **Task Definition**: The developer defines a task or requirement (e.g., implement a feature, fix a bug, refactor code, write tests).
2.  **AI Prompting**: The developer prompts the AI assistant with specific instructions, providing context like existing code, project standards (`.clinerules`), and desired outcomes.
3.  **AI Generation & Execution**: The AI generates code, suggests solutions, writes tests, runs commands (like `bundle install`, `rspec`, `rubocop`), reads/writes files, or performs other development tasks using integrated tools.
4.  **Developer Review**: The developer carefully reviews the AI's output, suggestions, and actions.
5.  **Feedback & Refinement**: The developer provides feedback to the AI, requesting modifications, corrections, or alternative approaches. The AI refines its work based on this feedback.
6.  **Integration**: The developer integrates the final, reviewed code into the project.

### Areas of AI Assistance

Throughout this project, the AI assistant has been utilized for various tasks, including:

-   **Code Generation**: Creating boilerplate code, implementing features based on specifications (e.g., controllers, models, migrations, services).
-   **Testing**: Generating RSpec tests (unit, controller, request specs), updating test scripts (`test_api.zsh`).
-   **Refactoring**: Improving existing code structure, readability, and performance.
-   **Debugging**: Identifying and fixing errors in code and tests.
-   **Dependency Management**: Updating gems (`bundle update`), resolving conflicts.
-   **Code Style & Linting**: Running `rubocop -A` and applying corrections to adhere to style guides.
-   **Documentation**: Generating comments and updating documentation files (like this README).
-   **Workflow Enforcement**: Following steps outlined in `DEVELOPMENT_WORKFLOW.md` and adhering to rules defined in `.clinerules`.

### Benefits

-   **Increased Velocity**: Faster implementation of features and resolution of issues.
-   **Improved Code Quality**: Assistance in adhering to best practices, style guides, and testing standards.
-   **Enhanced Consistency**: Ensuring consistent patterns and approaches across the codebase.
-   **Exploration**: Quickly exploring different implementation options or refactoring strategies.

**Note**: While the AI assistant significantly accelerates development, the developer remains responsible for guiding the process, reviewing all outputs, ensuring correctness, and making final decisions.

## Testing

The application uses RSpec for testing:

- **Unit Tests**: For models and service objects
- **Controller Tests**: For API endpoints
- **Integration Tests**: For complete user flows
- **Test Coverage**: Maintained above 95%

### Code Quality Metrics

- RuboCop for style enforcement
- SimpleCov for test coverage
- CI/CD pipeline for automated testing

## Deployment

### Staging Environment

- Automatic deployment from the `staging` branch
- Configuration via environment variables
- Staging-specific database

### Production Environment

- Manual deployment from `main` branch
- Zero-downtime deployment strategy
- Regular database backups
- Performance monitoring

## Contributing

1. Fork the repository
2. Create a feature branch
3. Implement your changes with tests
4. Submit a pull request
5. Ensure CI tests pass

## License

This project is licensed under the [MIT License](LICENSE).

