#!/usr/bin/env ruby
# frozen_string_literal: true

require 'open3'
require 'io/console'

def header(text)
  puts "\n\e[1;34m#{text}\e[0m"
  puts '=' * text.length
end

def success(text)
  puts "\e[32m✓ #{text}\e[0m"
end

def error(text)
  puts "\e[31m✗ #{text}\e[0m"
end

def warning(text)
  puts "\e[33m! #{text}\e[0m"
end

def info(text)
  puts "\e[36mi #{text}\e[0m"
end

def run_command(command, show_output: true)
  success "Running: #{command}" if show_output
  stdout, stderr, status = Open3.capture3(command)

  if status.success?
    puts stdout if show_output && !stdout.empty?
    { success: true, output: stdout }
  else
    error "Command failed: #{command}"
    puts stderr unless stderr.empty?
    { success: false, error: stderr }
  end
end

header 'PostgreSQL Setup for Project X'
puts "This script will guide you through setting up PostgreSQL for your Rails application.\n\n"

# Check if PostgreSQL is installed
header 'Step 1: Checking PostgreSQL Installation'
pg_check = run_command('which psql', show_output: false)

if pg_check[:success]
  success "PostgreSQL client is installed at: #{pg_check[:output].strip}"

  # Check PostgreSQL version
  version_check = run_command('psql --version', show_output: false)
  puts version_check[:output] if version_check[:success]
else
  error 'PostgreSQL client (psql) not found. Please install PostgreSQL:'
  info '  macOS:   brew install postgresql@15'
  info '  Ubuntu:  sudo apt install postgresql postgresql-contrib'
  exit 1
end

# Check if PostgreSQL server is running
header 'Step 2: Checking PostgreSQL Server'
pg_running = run_command('pg_isready', show_output: false)

if pg_running[:success] && pg_running[:output].include?('accepting connections')
  success 'PostgreSQL server is running and accepting connections'
else
  error 'PostgreSQL server is not running or not accepting connections'
  info '  macOS:   brew services start postgresql@15'
  info '  Ubuntu:  sudo service postgresql start'
  warning 'Please start PostgreSQL and then run this script again'
  exit 1
end

# Check connection with current credentials
header 'Step 3: Testing Database Connection'
puts 'Trying to connect to PostgreSQL with current .env credentials...'

current_user = ENV['PG_USER'] || 'postgres'
current_pass = ENV['PG_PASSWORD'] || ''

connection_test = run_command("PGPASSWORD='#{current_pass}' psql -U #{current_user} -h localhost -c '\\conninfo'",
                              show_output: false)

if connection_test[:success]
  success 'Successfully connected to PostgreSQL with current credentials'
  puts connection_test[:output]
else
  warning "Could not connect with current credentials, let's update them"

  print 'Enter PostgreSQL username (default: postgres): '
  pg_user = gets.chomp
  pg_user = 'postgres' if pg_user.empty?

  print 'Enter PostgreSQL password: '
  pg_pass = $stdin.noecho(&:gets).chomp
  puts

  # Update .env file
  begin
    env_content = File.read('.env')
    env_content.gsub!(/PG_USER=.*/, "PG_USER=#{pg_user} # PostgreSQL username")
    env_content.gsub!(/PG_PASSWORD=.*/, "PG_PASSWORD=#{pg_pass} # PostgreSQL password")
    File.write('.env', env_content)
    success 'Updated .env file with new credentials'
  rescue StandardError => e
    error "Failed to update .env file: #{e.message}"
    exit 1
  end

  # Test connection with new credentials
  connection_test = run_command("PGPASSWORD='#{pg_pass}' psql -U #{pg_user} -h localhost -c '\\conninfo'",
                                show_output: false)

  if connection_test[:success]
    success 'Successfully connected with new credentials'
  else
    error 'Still cannot connect to PostgreSQL. Please check your credentials and ensure PostgreSQL is correctly set up'
    exit 1
  end
end

# Remove SQLite files
header 'Step 4: Removing SQLite Files'
sqlite_files = Dir.glob('db/*.sqlite3*')

if sqlite_files.any?
  puts 'Found SQLite database files:'
  sqlite_files.each { |file| puts "  - #{file}" }

  print 'Do you want to remove these files? (y/n): '
  confirm = gets.chomp.downcase

  if confirm == 'y'
    sqlite_files.each do |file|
      File.delete(file)
      success "Deleted #{file}"
    end
  else
    warning 'Skipped removing SQLite files'
  end
else
  info 'No SQLite files found'
end

# Create PostgreSQL databases
header 'Step 5: Setting up PostgreSQL Databases'
puts 'Creating databases, running migrations, and seeding data...'

steps = [
  { command: 'bundle exec rails db:create', message: 'Creating databases' },
  { command: 'bundle exec rails db:migrate', message: 'Running migrations' },
  { command: 'bundle exec rails db:seed', message: 'Seeding database' }
]

steps.each do |step|
  puts "\n#{step[:message]}..."
  result = run_command(step[:command])

  next if result[:success]

  error "Failed to #{step[:message].downcase}"
  warning 'Please fix the issues and try again'
  exit 1
end

# Verify setup
header 'Step 6: Verifying PostgreSQL Setup'
db_version = run_command('bundle exec rails db:version', show_output: false)

if db_version[:success]
  success 'PostgreSQL setup completed successfully!'
  success "Current database version: #{db_version[:output].strip}"

  # Test database connection through Rails
  rails_check = run_command("bundle exec rails runner 'puts ActiveRecord::Base.connected?'", show_output: false)
  if rails_check[:success] && rails_check[:output].strip == 'true'
    success 'Rails is successfully connected to PostgreSQL'
  else
    warning 'Rails may not be properly connected to PostgreSQL, check your configuration'
  end
else
  error 'Could not verify database version. PostgreSQL setup may not be complete'
end

puts "\n\e[1m✨ PostgreSQL setup process completed! ✨\e[0m"
info 'If you encounter any issues, check the documentation in docs/POSTGRES_SETUP.md'
