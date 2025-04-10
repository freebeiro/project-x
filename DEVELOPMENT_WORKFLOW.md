# Development Workflow Checklist

This document outlines the step-by-step process for implementing new features in the SW Dev Group Dating App backend, ensuring compliance with all project rules and standards.

## Table of Contents
1. [Analysis Phase](#1-analysis-phase)
2. [Feature Branch Creation](#2-feature-branch-creation)
3. [Initial Implementation](#3-initial-implementation)
4. [API Testing Verification](#4-api-testing-verification)
5. [Add Test Coverage](#5-add-test-coverage)
6. [Refactoring and Compliance](#6-refactoring-and-compliance)
7. [Final Verification and Commit](#7-final-verification-and-commit)
8. [Pull Request](#8-pull-request)

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

## 3. Initial Implementation

Focus on creating a clean, simple, and working version of the feature. Defer complex optimizations and strict rule adherence for the refactoring phase.

- [ ] **Database Migrations**: Create necessary migrations following the database guidelines.
- [ ] **Model Implementation**: Implement core models with basic validations/associations.
- [ ] **Service Implementation**: Implement essential service logic if needed.
- [ ] **Controller Implementation**: Implement controllers to handle requests and responses.
- [ ] **Route Configuration**: Update routes.rb with new endpoints.

**✓ Completion Criteria**: A basic, functional implementation of the feature exists.

## 4. API Testing Verification

Ensure the initial implementation works correctly from an external perspective using API tests.

- [ ] **Start Development Server**: `rails s -p 3005`
- [ ] **Create CURL Requests**: Add CURL requests to test each new endpoint's core functionality.
- [ ] **Test Happy Path**: Verify successful operations with valid inputs.
- [ ] **Test Basic Error Cases**: Verify handling of obviously invalid inputs or unauthorized access if applicable.
- [ ] **Document CURL Commands**: Save working CURL commands for inclusion in test_api.zsh.
- [ ] **Update test_api.zsh**: Add new CURL tests to the test script.
- [ ] **Run Full API Test**: Execute `./scripts/test_api.zsh` to verify the new feature works and doesn't break existing endpoints.

**✓ Completion Criteria**: The initial implementation passes all relevant tests in `./scripts/test_api.zsh`.

## 5. Add Test Coverage

Write comprehensive automated tests (RSpec) for the implemented code.

- [ ] **Write Model Specs**: Test validations, associations, and methods thoroughly.
- [ ] **Write Controller Specs**: Test API endpoints, authentication, parameter handling, and responses.
- [ ] **Write Service Specs**: Test business logic in service objects if applicable.
- [ ] **Run RSpec**: `bundle exec rspec` to verify all tests pass.
- [ ] **Check Coverage**: Ensure test coverage is above 90% (adjust target as needed).

**✓ Completion Criteria**: All RSpec tests pass and test coverage meets the project target (>90%).

## 6. Refactoring and Compliance

Refactor the working code to meet all project standards, best practices, and rules.

- [ ] **Refactor for SOLID/Rails Way**: Improve code structure, reduce complexity, follow conventions.
- [ ] **Address `.clinerules`**: Ensure compliance with specific rules (e.g., 150-line limit, no duplication).
- [ ] **Run RuboCop**: `bundle exec rubocop -A` to automatically fix style issues.
- [ ] **Manual RuboCop Fixes**: Address any remaining RuboCop violations manually.
- [ ] **Rerun All Tests**: Verify that refactoring didn't break functionality:
    - [ ] `bundle exec rspec`
    - [ ] `./scripts/test_api.zsh`
- [ ] **Final Code Review**: Self-review the refactored code for clarity, efficiency, and compliance.

**✓ Completion Criteria**: Code is refactored, complies with all `.clinerules` and RuboCop, and all tests (RSpec & API) still pass.

## 7. Final Verification and Commit

Perform final checks and commit changes.

- [ ] **Run Full Test Suite**: `bundle exec rspec`
- [ ] **Run API Tests**: `./scripts/test_api.zsh`
- [ ] **Check Coverage Report**: Verify coverage is still above target (>90%).
- [ ] **Run RuboCop**: `bundle exec rubocop` (should have no offenses).
- [ ] **Review Changes**: `git diff` to review all changes.
- [ ] **Stage Changes**: `git add .`
- [ ] **Commit Changes**: `git commit -m "Descriptive commit message (#issue-number)"`
- [ ] **Push Changes**: `git push origin feature/feature-name`

**✓ Completion Criteria**: All tests pass, code quality checks pass, and changes are committed and pushed.

## 8. Pull Request

Create a pull request for code review and merging.

- [ ] **Create PR**: Create a pull request from your feature branch to main.
- [ ] **PR Description**: Include a clear description of the changes.
- [ ] **Link Issues**: Reference related issues in the PR description.
- [ ] **CI Checks**: Verify that CI checks pass.
- [ ] **Code Review**: Address any feedback from code review.
- [ ] **Final Approval**: Get final approval from a reviewer.
- [ ] **Merge**: Merge the PR into main.

**✓ Completion Criteria**: PR is approved and merged into main.

## Important Considerations

### Iterative Development
- This workflow is iterative. If adding tests (Step 5) or refactoring (Step 6) reveals issues with the initial implementation (Step 3) or API tests (Step 4), revisit those earlier steps to make corrections before proceeding.
- Always run relevant tests after making changes during any phase.

### Continuous Verification
- Regularly run tests (`rspec`, `./scripts/test_api.zsh`) and quality checks (`rubocop`) throughout development, not just at the designated steps.
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
