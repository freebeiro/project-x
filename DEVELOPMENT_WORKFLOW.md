# Development Workflow Checklist

This document outlines the step-by-step process for implementing new features in the SW Dev Group Dating App backend, ensuring compliance with all project rules and standards.

## Table of Contents
1. [Analysis Phase](#1-analysis-phase)
2. [Feature Branch Creation](#2-feature-branch-creation)
3. [Implementation Phase](#3-implementation-phase)
4. [API Testing with CURL](#4-api-testing-with-curl)
5. [Test Coverage and Code Quality](#5-test-coverage-and-code-quality)
6. [Final Verification and Commit](#6-final-verification-and-commit)
7. [Pull Request](#7-pull-request)

## 1. Analysis Phase

Before writing any code, thoroughly analyze the requirements and existing codebase.

- [ ] **Review Requirements**: Clearly understand what needs to be implemented
- [ ] **Check Existing Code**: Verify if similar functionality already exists that can be reused
- [ ] **Identify Affected Components**: Determine which models, controllers, and services will be affected
- [ ] **Plan Database Changes**: Identify any necessary migrations or schema changes
- [ ] **Security Review**: Consider authentication, authorization, and data protection requirements
- [ ] **API Design**: Plan the API endpoints following RESTful conventions
- [ ] **Dependency Analysis**: Identify any new gems or dependencies needed

**✓ Completion Criteria**: A clear understanding of what needs to be built and how it fits into the existing architecture.

## 2. Feature Branch Creation

Create a properly named feature branch from the main branch.

- [ ] **Update Main Branch**: `git checkout main && git pull origin main`
- [ ] **Create Feature Branch**: `git checkout -b feature/feature-name` (use descriptive name)
- [ ] **Verify Branch**: Ensure you're on the correct branch with `git branch`

**✓ Completion Criteria**: A new feature branch created from the latest main branch.

## 3. Implementation Phase

Implement the feature following project standards and best practices.

- [ ] **Database Migrations**: Create necessary migrations following the database guidelines
- [ ] **Model Implementation**: Implement models with proper validations and associations
- [ ] **Service Implementation**: Create service objects for complex business logic
- [ ] **Controller Implementation**: Implement controllers with proper authentication and error handling
- [ ] **Route Configuration**: Update routes.rb with new endpoints
- [ ] **Code Review**: Self-review code for compliance with:
  - [ ] 150-line limit for files
  - [ ] No code duplication
  - [ ] SOLID principles
  - [ ] Security best practices
  - [ ] Proper error handling
  - [ ] Meaningful variable and method names

**✓ Completion Criteria**: Feature implementation complete with all necessary components.

## 4. API Testing with CURL

Create and test API endpoints with CURL requests before writing automated tests.

- [ ] **Start Development Server**: `rails s -p 3005`
- [ ] **Create CURL Requests**: Add CURL requests to test each new endpoint
- [ ] **Test Happy Path**: Verify successful operations
- [ ] **Test Edge Cases**: Verify handling of invalid inputs, unauthorized access, etc.
- [ ] **Document CURL Commands**: Save working CURL commands for inclusion in test_api.zsh
- [ ] **Update test_api.zsh**: Add new CURL tests to the test script
- [ ] **Run Full API Test**: Execute `./scripts/test_api.zsh` to verify all endpoints still work

**✓ Completion Criteria**: All API endpoints can be successfully called via CURL and the test_api.zsh script passes.

## 5. Test Coverage and Code Quality

Ensure comprehensive test coverage and code quality.

- [ ] **Write Model Specs**: Test validations, associations, and methods
- [ ] **Write Controller Specs**: Test API endpoints, authentication, and error handling
- [ ] **Write Service Specs**: Test business logic in service objects
- [ ] **Run RSpec**: `bundle exec rspec` to verify all tests pass
- [ ] **Check Coverage**: Ensure test coverage is above 95%
- [ ] **Run RuboCop**: `bundle exec rubocop` to check code style
- [ ] **Fix RuboCop Issues**: Address any code style violations
- [ ] **Rerun Tests**: Verify that fixing RuboCop issues didn't break functionality

**✓ Completion Criteria**: All tests pass, test coverage is above 95%, and there are no RuboCop violations.

## 6. Final Verification and Commit

Perform final checks and commit changes.

- [ ] **Run Full Test Suite**: `bundle exec rspec`
- [ ] **Run API Tests**: `./scripts/test_api.zsh`
- [ ] **Check Coverage Report**: Verify coverage is still above 95%
- [ ] **Run RuboCop**: `bundle exec rubocop`
- [ ] **Review Changes**: `git diff` to review all changes
- [ ] **Stage Changes**: `git add .`
- [ ] **Commit Changes**: `git commit -m "Descriptive commit message (#issue-number)"`
- [ ] **Push Changes**: `git push origin feature/feature-name`

**✓ Completion Criteria**: All tests pass, code quality checks pass, and changes are committed and pushed.

## 7. Pull Request

Create a pull request for code review and merging.

- [ ] **Create PR**: Create a pull request from your feature branch to main
- [ ] **PR Description**: Include a clear description of the changes
- [ ] **Link Issues**: Reference related issues in the PR description
- [ ] **CI Checks**: Verify that CI checks pass
- [ ] **Code Review**: Address any feedback from code review
- [ ] **Final Approval**: Get final approval from a reviewer
- [ ] **Merge**: Merge the PR into main

**✓ Completion Criteria**: PR is approved and merged into main.

## Important Considerations

### Iterative Development
- If implementing later steps breaks earlier steps, return to the appropriate step and fix the issues before proceeding.
- Always run the full test suite after making significant changes to ensure nothing was broken.

### Continuous Verification
- Regularly run tests and quality checks throughout development, not just at the end.
- Use `git stash` to temporarily save changes if you need to switch context.

### Documentation
- Update documentation as you implement features.
- Include comments for complex logic.

### Security
- Never commit sensitive information like API keys or credentials.
- Always use environment variables for sensitive data.

### Code Quality
- Remember the 150-line limit for files.
- Keep methods short and focused.
- Follow the "no code duplication" rule strictly.

By following this workflow and checklist, we ensure that all features are implemented according to project standards and best practices, maintaining high code quality and test coverage throughout the development process.
