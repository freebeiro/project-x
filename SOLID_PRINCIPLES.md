# SOLID Principles Guide

This document provides guidance on implementing SOLID principles in the SW Dev Group Dating App backend. These principles help create maintainable, flexible, and robust code.

## Table of Contents

1. [Single Responsibility Principle (SRP)](#single-responsibility-principle-srp)
2. [Open/Closed Principle (OCP)](#openclosed-principle-ocp)
3. [Liskov Substitution Principle (LSP)](#liskov-substitution-principle-lsp)
4. [Interface Segregation Principle (ISP)](#interface-segregation-principle-isp)
5. [Dependency Inversion Principle (DIP)](#dependency-inversion-principle-dip)
6. [Implementation Examples](#implementation-examples)

## Single Responsibility Principle (SRP)

> A class should have only one reason to change.

### Guidelines:

1. **Identify the core responsibility** of each class or module
2. **Extract separate responsibilities** into their own classes
3. **Watch for code smells** like large classes or methods

### Implementation in Rails:

- **Controllers**: Handle HTTP requests/responses only
- **Models**: Manage data structure and simple validations
- **Service Objects**: Encapsulate complex business logic
- **Query Objects**: Handle complex database queries
- **Form Objects**: Manage complex form processing
- **Serializers**: Handle data transformation for APIs
- **Validators**: Implement complex validation logic

### Example:

```ruby
# BAD - UserController doing too much
class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
    
    if @user.save
      # Send welcome email
      UserMailer.welcome_email(@user).deliver_later
      
      # Log registration
      RegistrationLogger.log(@user)
      
      # Create initial profile
      Profile.create(user_id: @user.id)
      
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end
end

# GOOD - Using a service object
class UsersController < ApplicationController
  def create
    result = UserRegistrationService.new(user_params).execute
    
    if result.success?
      render json: result.user, status: :created
    else
      render json: result.errors, status: :unprocessable_entity
    end
  end
end

class UserRegistrationService
  def initialize(user_params)
    @user_params = user_params
    @result = OpenStruct.new(success?: false)
  end
  
  def execute
    create_user
    if @result.success?
      send_welcome_email
      log_registration
      create_initial_profile
    end
    @result
  end
  
  private
  
  def create_user
    @user = User.new(@user_params)
    if @user.save
      @result.success? = true
      @result.user = @user
    else
      @result.errors = @user.errors
    end
  end
  
  def send_welcome_email
    UserMailer.welcome_email(@user).deliver_later
  end
  
  def log_registration
    RegistrationLogger.log(@user)
  end
  
  def create_initial_profile
    Profile.create(user_id: @user.id)
  end
end
```

## Open/Closed Principle (OCP)

> Software entities (classes, modules, functions, etc.) should be open for extension, but closed for modification.

### Guidelines:

1. **Design for extension**: Allow behavior to be extended without modifying source code
2. **Use abstractions**: Rely on interfaces and abstract classes
3. **Implement variations with inheritance or composition**

### Implementation in Rails:

- **Concerns**: Share functionality across models or controllers
- **Service Objects**: Design with extension points
- **Strategy Pattern**: Vary behavior through different implementations
- **Decorator Pattern**: Add functionality without modifying classes

### Example:

```ruby
# BAD - Hard-coded notification types
class NotificationService
  def send_notification(user, message, type)
    case type
    when :email
      # Email logic
    when :sms
      # SMS logic
    when :push
      # Push notification logic
    end
  end
end

# GOOD - Extensible with new notification types
class NotificationService
  def initialize(notifiers = [])
    @notifiers = notifiers
  end
  
  def send_notification(user, message)
    @notifiers.each { |notifier| notifier.notify(user, message) }
  end
end

class EmailNotifier
  def notify(user, message)
    # Email notification logic
  end
end

class SmsNotifier
  def notify(user, message)
    # SMS notification logic
  end
end

class PushNotifier
  def notify(user, message)
    # Push notification logic
  end
end

# Usage
notifiers = [EmailNotifier.new, SmsNotifier.new]
notification_service = NotificationService.new(notifiers)
notification_service.send_notification(user, "Hello!")
```

## Liskov Substitution Principle (LSP)

> Objects in a program should be replaceable with instances of their subtypes without altering the correctness of that program.

### Guidelines:

1. **Subtypes must fulfill the contracts of their base types**
2. **Don't strengthen preconditions in subtypes**
3. **Don't weaken postconditions in subtypes**
4. **Preserve invariants of the base type**
5. **No new exceptions in subtypes unless they're subtypes of exceptions in the base**

### Implementation in Rails:

- **Inheritance hierarchies**: Ensure child classes can replace parent classes
- **Duck typing**: Rely on behavior rather than concrete types
- **Interfaces**: Define clear contracts for classes

### Example:

```ruby
# BAD - Violating LSP
class Rectangle
  attr_accessor :width, :height
  
  def area
    width * height
  end
end

class Square < Rectangle
  def width=(value)
    @width = value
    @height = value  # Violates LSP by changing behavior
  end
  
  def height=(value)
    @width = value  # Violates LSP by changing behavior
    @height = value
  end
end

# GOOD - Following LSP
class Shape
  def area
    raise NotImplementedError
  end
end

class Rectangle < Shape
  attr_accessor :width, :height
  
  def area
    width * height
  end
end

class Square < Shape
  attr_accessor :side
  
  def area
    side * side
  end
end
```

## Interface Segregation Principle (ISP)

> No client should be forced to depend on methods it does not use.

### Guidelines:

1. **Create small, focused interfaces** rather than large, monolithic ones
2. **Split large interfaces** into more specific ones
3. **Clients should only need to know about methods they use**

### Implementation in Rails:

- **Concerns**: Create focused, single-purpose concerns
- **Service Objects**: Design with specific interfaces
- **Query Objects**: Focused on specific query needs

### Example:

```ruby
# BAD - Kitchen sink interface
class UserService
  def create_user(params)
    # Create user logic
  end
  
  def update_user(user, params)
    # Update user logic
  end
  
  def delete_user(user)
    # Delete user logic
  end
  
  def send_welcome_email(user)
    # Email logic
  end
  
  def generate_auth_token(user)
    # Token generation logic
  end
  
  def reset_password(user)
    # Password reset logic
  end
end

# GOOD - Segregated interfaces
class UserCreationService
  def create(params)
    # Create user logic
  end
end

class UserUpdateService
  def update(user, params)
    # Update user logic
  end
end

class UserDeletionService
  def delete(user)
    # Delete user logic
  end
end

class UserEmailService
  def send_welcome_email(user)
    # Email logic
  end
end

class AuthenticationService
  def generate_token(user)
    # Token generation logic
  end
  
  def reset_password(user)
    # Password reset logic
  end
end
```

## Dependency Inversion Principle (DIP)

> High-level modules should not depend on low-level modules. Both should depend on abstractions.
> Abstractions should not depend on details. Details should depend on abstractions.

### Guidelines:

1. **Depend on abstractions** rather than concrete implementations
2. **Use dependency injection** to provide dependencies
3. **Define clear interfaces** between components

### Implementation in Rails:

- **Service Objects**: Accept dependencies in constructors
- **Dependency Injection**: Inject collaborators instead of instantiating them
- **Adapters**: Create adapters for external services

### Example:

```ruby
# BAD - Tight coupling to specific implementations
class UserNotifier
  def notify(user, message)
    # Direct instantiation of a concrete class
    emailer = AmazonSESEmailer.new
    emailer.send_email(user.email, message)
  end
end

# GOOD - Dependency injection and abstractions
class UserNotifier
  def initialize(email_service)
    @email_service = email_service
  end
  
  def notify(user, message)
    @email_service.send_email(user.email, message)
  end
end

# Different implementations of the email service interface
class AmazonSESEmailer
  def send_email(address, message)
    # Amazon SES implementation
  end
end

class SendgridEmailer
  def send_email(address, message)
    # Sendgrid implementation
  end
end

# Usage
emailer = AmazonSESEmailer.new
notifier = UserNotifier.new(emailer)
notifier.notify(user, "Hello!")

# Easy to switch implementations
emailer = SendgridEmailer.new
notifier = UserNotifier.new(emailer)
notifier.notify(user, "Hello!")
```

## Implementation Examples

### Controllers

```ruby
# Following SRP: Thin controller delegating to service
class FriendshipsController < ApplicationController
  before_action :authenticate_user_from_token!

  def create
    result = FriendshipService.new(current_user).create_friendship(friendship_params)
    
    if result.success?
      render json: result.friendship, status: :created
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end
  
  def accept
    result = FriendshipService.new(current_user).accept_friendship(params[:id])
    
    if result.success?
      render json: result.friendship
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end
  
  private
  
  def friendship_params
    params.require(:friendship).permit(:friend_id)
  end
end
```

### Services

```ruby
# Following SRP, OCP, DIP
class FriendshipService
  def initialize(user, notifier = UserNotifier.new)
    @user = user
    @notifier = notifier
  end
  
  def create_friendship(params)
    friendship = @user.friendships.new(friend_id: params[:friend_id], status: 'pending')
    
    result = OpenStruct.new(success?: false)
    
    if friendship.save
      @notifier.notify_friendship_request(friendship)
      result.success? = true
      result.friendship = friendship
    else
      result.errors = friendship.errors
    end
    
    result
  end
  
  def accept_friendship(friendship_id)
    friendship = Friendship.find_by(id: friendship_id, friend_id: @user.id)
    
    result = OpenStruct.new(success?: false)
    
    if friendship.nil?
      result.errors = ['Friendship not found']
    elsif friendship.update(status: 'accepted')
      create_reciprocal_friendship(friendship)
      @notifier.notify_friendship_accepted(friendship)
      result.success? = true
      result.friendship = friendship
    else
      result.errors = friendship.errors
    end
    
    result
  end
  
  private
  
  def create_reciprocal_friendship(friendship)
    Friendship.create(
      user_id: friendship.friend_id,
      friend_id: friendship.user_id,
      status: 'accepted'
    )
  end
end
```

### Models

```ruby
# Following SRP, using concerns for shared functionality
class User < ApplicationRecord
  include Searchable
  
  # Associations
  has_one :profile, dependent: :destroy
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships, source: :friend
  has_many :group_memberships, dependent: :destroy
  has_many :groups, through: :group_memberships
  
  # Validations
  validates :email, presence: true, uniqueness: true
  validates :date_of_birth, presence: true
  validate :minimum_age_requirement
  
  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_email, ->(email) { where("email LIKE ?", "%#{email}%") }
  
  private
  
  def minimum_age_requirement
    return unless date_of_birth.present?
    
    min_age = 16
    if date_of_birth > min_age.years.ago.to_date
      errors.add(:date_of_birth, "must be at least #{min_age} years ago")
    end
  end
end

# Concern following SRP
module Searchable
  extend ActiveSupport::Concern
  
  included do
    scope :search, ->(query) { where("email LIKE ? OR username LIKE ?", "%#{query}%", "%#{query}%") }
  end
  
  class_methods do
    def search_by_criteria(criteria = {})
      scope = all
      scope = scope.by_email(criteria[:email]) if criteria[:email].present?
      scope = scope.joins(:profile).where("profiles.username LIKE ?", "%#{criteria[:username]}%") if criteria[:username].present?
      scope
    end
  end
end
```

By following these SOLID principles, we can create a codebase that is:

1. **Easier to maintain** - Single responsibility makes changes safer
2. **More flexible** - Open/closed allows extensions without modifying existing code
3. **More stable** - Liskov substitution ensures consistent behavior
4. **More cohesive** - Interface segregation creates focused components
5. **Less coupled** - Dependency inversion reduces tight coupling between components

Always be mindful of these principles when developing new features or modifying existing code. 