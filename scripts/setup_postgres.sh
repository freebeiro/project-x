#!/bin/bash

echo "Setting up PostgreSQL for Project X"

# Step 1: Remove SQLite database files
echo "Removing SQLite database files..."
rm -f db/development.sqlite3
rm -f db/development.sqlite3-shm
rm -f db/development.sqlite3-wal
rm -f db/test.sqlite3
echo "SQLite files removed."

# Step 2: Create PostgreSQL databases
echo "Creating PostgreSQL databases..."
rails db:create
echo "PostgreSQL databases created."

# Step 3: Run migrations
echo "Running migrations..."
rails db:migrate
echo "Migrations completed."

# Step 4: Seed the database (if needed)
echo "Seeding the database..."
rails db:seed
echo "Database seeded."

echo "PostgreSQL setup completed!"
