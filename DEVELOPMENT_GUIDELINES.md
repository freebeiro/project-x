# Development Guidelines

This document outlines the development guidelines for the SW Dev Group Dating App backend. Following these guidelines ensures a consistent, maintainable, and high-quality codebase.

## Table of Contents

1. [Development Workflow](#development-workflow)
2. [Code Style and Standards](#code-style-and-standards)
3. [Version Control Guidelines](#version-control-guidelines)
4. [Testing Requirements](#testing-requirements)
5. [Documentation Requirements](#documentation-requirements)
6. [Security Guidelines](#security-guidelines)
7. [Performance Considerations](#performance-considerations)
8. [Code Review Process](#code-review-process)
9. [Deployment Process](#deployment-process)

## Development Workflow

### Setup

1. Clone the repository
2. Install dependencies using `bundle install`
3. Set up the database with `rails db:create db:migrate`
4. Optionally seed the database with `rails db:seed`
5. Create a `.env` file for environment variables

### Feature Development Process

1. **Understand Requirements**: Fully understand the requirements before starting
2. **Create Feature Branch**: Create a branch from `main`
3. **Design**: Plan your implementation, considering architecture and interfaces
4. **Test-Driven Development**:
   - Write failing tests first
   - Implement functionality to make tests pass
   - Refactor code
5. **Code Review**: Submit PR for code review
6. **Testing**: Ensure all automated tests pass
7. **Deployment**: Merge to `main` after approval

## Code Style and Standards

### Ruby Style

- Follow the [Ruby Style Guide](https://github.com/rubocop/ruby-style-guide)
- Run RuboCop before committing: `bundle exec rubocop`
- Maximum method length: 10 lines
- Maximum class length: 100 lines
- Use meaningful variable names

### Rails Conventions

- Follow Rails naming conventions
- Use proper RESTful routing
- Keep controllers thin, models fat (but not too fat)
- Use service objects for complex business logic
- Use concerns for shared functionality

### File Organization

- Controllers in `app/controllers/`
- Models in `app/models/`
- Service objects in `app/services/`
- Form objects in `app/forms/`
- Query objects in `app/queries/`
- Serializers in `app/serializers/`
- Validators in `app/validators/`
- Concerns in `app/models/concerns/` or `app/controllers/concerns/`

## Version Control Guidelines

### Branching Strategy

- `main` - Production-ready code
- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `hotfix/*` - Critical fixes for production

### Commit Messages

- Use imperative mood: "Add feature" not "Added feature"
- First line should be 50 characters or less
- Include issue/ticket reference if applicable
- Provide detailed description if necessary

Format:
```
[Type]: Brief description

Detailed description explaining the changes made and why.

Fixes #123
```

Types:
- `Feat`: New feature
- `Fix`: Bug fix
- `Docs`: Documentation change
- `Style`: Formatting, missing semicolons, etc.
- `Refactor`: Code change that neither fixes a bug nor adds a feature
- `Test`: Adding or refactoring tests
- `Chore`: Updating build tasks, package manager configs, etc.

### Pull Requests

- Create descriptive PRs with clear titles
- Link related issues
- Include test plan
- Assign appropriate reviewers
- Address all review comments
- Squash commits before merging

## Testing Requirements

### Test Coverage

- Minimum coverage: 95%
- Use SimpleCov to measure coverage

### Test Types

- **Unit Tests**: Test individual components
- **Controller Tests**: Test API endpoints
- **Integration Tests**: Test flows across components
- **System Tests**: Test entire system behavior

### Testing Guidelines

- Tests should be independent
- Use factories instead of fixtures
- Use meaningful test descriptions
- Follow the Arrange-Act-Assert pattern
- Test both happy paths and edge cases

## Documentation Requirements

### Code Documentation

- Document public methods with descriptions and parameters
- Document complex algorithms and business logic
- Keep comments up-to-date with code changes

### API Documentation

- Document all API endpoints
- Include request/response examples
- Specify authentication requirements
- Document error responses and codes

### README

- Keep README updated with setup instructions
- Include development workflow
- Document environment variables
- Include testing instructions

## Security Guidelines

### Authentication & Authorization

- Use JWT for authentication
- Implement proper authorization checks
- Use secure token generation
- Implement token expiration and blacklisting

### Data Protection

- Validate all user inputs
- Protect against SQL injection
- Protect against XSS attacks
- Implement proper CORS policies
- Encrypt sensitive data

### Compliance

- Ensure GDPR compliance
- Ensure CCPA compliance
- Ensure COPPA compliance for users under 18

## Performance Considerations

### Database

- Use proper indexing
- Optimize queries
- Avoid N+1 queries
- Use pagination for large datasets
- Consider using counter caches

### Caching

- Cache frequently accessed data
- Use Russian Doll caching when appropriate
- Set appropriate cache expiration times

### Background Jobs

- Use background jobs for long-running tasks
- Implement proper job retries and error handling
- Monitor job queue performance

## Code Review Process

### Review Checklist

- Does the code follow our style guidelines?
- Is the code well-tested?
- Is the code secure?
- Is the code efficient?
- Is the code maintainable?
- Is the code properly documented?
- Does the code meet requirements?

### Review Process

1. Developer submits PR
2. Reviewers assigned
3. Reviewers provide feedback
4. Developer addresses feedback
5. PR approved when all issues addressed
6. PR merged by developer

## Deployment Process

### Environments

- Development: Local development environment
- Staging: For testing before production
- Production: Live environment

### Deployment Steps

1. Run all tests
2. Run linters
3. Create release branch
4. Deploy to staging
5. Test in staging
6. Deploy to production
7. Verify in production

### Rollback Procedure

1. Identify issue
2. Decide on rollback vs. hotfix
3. If rollback, revert to last stable version
4. If hotfix, create hotfix branch
5. Deploy fix to production
6. Verify fix

By following these guidelines, we ensure a high-quality, maintainable codebase that is easy to extend and modify as requirements change.
