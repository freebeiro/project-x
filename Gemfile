# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.3.0'

# Rails framework
gem 'rails', '~> 7.1.4'

# Database
gem 'pg', '~> 1.2'
gem 'sqlite3', '>= 1.4'

# Web server
gem 'puma', '>= 5.0'

# Authentication
gem 'devise'

# API serialization
gem 'active_model_serializers', '~> 0.10.0'

# Background jobs
gem 'sidekiq'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# gem "rack-cors"

group :development, :test do
  # Debugging
  gem 'byebug'
  gem 'debug', platforms: %i[mri windows]

  # Testing
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov', require: false

  # Environment variables
  gem 'dotenv-rails'
end

group :test do
  gem 'rails-controller-testing'
end

group :development do
  # Linting and Code Quality
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

# Uncomment these if needed:
# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

gem 'jwt'

gem 'rspec_junit_formatter', '~> 0.6.0', group: :development
