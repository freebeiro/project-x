# Development Guidelines

This document outlines the development guidelines for the SW Dev Group Dating App backend. Following these guidelines ensures a consistent, maintainable, and high-quality codebase.

## Critical Development Rules

The following rules are to be strictly followed without exception:

1. **Avoid Code Duplication at All Costs**: 
   - Before implementing new logic, thoroughly check if similar functionality already exists
   - Refactor and reuse existing code even if it requires modification
   - Functionality duplication is considered a violation even if the implementation is different

2. **Strict File Size Limit**:
   - No file may exceed 150 lines of code under ANY circumstances
   - If a file approaches this limit, it must be split into multiple files with focused responsibilities
   - This rule enforces the Single Responsibility Principle

3. **Comprehensive Testing Requirements**:
   - All code must have associated specs with proper test coverage
   - Minimum test coverage for new code: 95%
   - Every feature must include both unit and integration tests

4. **Real-world Testing**:
   - All API endpoints must have corresponding curl request tests
   - The test script must pass all tests before a feature is considered complete
   - Tests must cover both happy paths and edge cases

5. **No Extraneous Code**:
   - Do not add code that isn't directly related to the requirements
   - This includes logging, comments, or even minor changes
   - Obtain express permission before adding anything beyond the immediate requirements

6. **Documentation**:
   - Every new file requires documentation explaining its purpose
   - Update documentation for any meaningful changes to existing files
   - Document the purpose, inputs, outputs, and side effects of classes and methods

7. **Implementation Methodology**:
   - When an implementation attempt fails, document what didn't work before trying again
   - Explain the new approach and reasoning before proceeding
   - Remove failed implementation code before attempting a new approach

8. **Code Cleanliness**:
   - Delete temporary/testing scripts after use
   - Remove unnecessary code after implementation
   - Final review should remove anything not essential for the feature

9. **Completion Requirements**:
   - Testing: All tests pass
   - Coverage: Meets minimum requirements
   - Quality: Passes RuboCop without warnings
   - Integration: All curl tests pass
   - Documentation: Updated for all changes
   - Version Control: Properly committed following workflow

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

1. **Understand Requirements**: 
   - Fully understand the requirements before starting
   - Identify existing code that might provide similar functionality
   - Plan how to implement without duplicating logic

2. **Create Feature Branch**: 
   - Create a branch from `main` using format `feature/feature-name`
   - Keep branches focused on a single feature

3. **Design**: 
   - Plan your implementation, considering architecture and interfaces
   - Identify files that may need to be created or modified
   - Ensure new files will adhere to the 150-line limit
   - Design with reuse in mind

4. **Test-Driven Development**:
   - Write failing tests first (both unit and API tests)
   - Create curl test cases for API endpoints
   - Implement functionality to make tests pass
   - Continuously run tests to ensure no regressions

5. **Implementation**:
   - Reuse existing code wherever possible
   - Keep files under 150 lines
   - If an implementation approach fails, document it and remove the code before trying a new approach
   - Add only code directly related to requirements
   - Document all new files and significant changes

6. **Code Review Preparation**:
   - Run all tests to ensure they pass
   - Verify test coverage meets minimum requirements
   - Run RuboCop and fix any issues
   - Run the curl test script to verify endpoints
   - Remove any unnecessary code or debugging tools
   - Review all changes for compliance with guidelines

7. **Code Review**: 
   - Submit PR for code review with clear description
   - Address all feedback
   - Re-run tests after making changes

8. **Documentation**:
   - Ensure all new files are documented
   - Update documentation for modified files
   - Document API changes if applicable

9. **Final Verification**:
   - Run all tests one final time
   - Verify everything works with the test script
   - Check for any remaining unnecessary code

10. **Merge and Deploy**: 
    - Merge to `main` after approval
    - Deploy following deployment process
    - Monitor for any issues

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
