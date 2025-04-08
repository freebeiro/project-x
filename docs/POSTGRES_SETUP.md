# PostgreSQL Setup for Project X

This guide will help you set up PostgreSQL for the Project X application.

## Prerequisites

1. PostgreSQL installed on your system
2. Ruby and Rails environment properly configured

## Installation

### macOS

Using Homebrew:
```bash
brew install postgresql@15
brew services start postgresql@15
```

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo service postgresql start
```

## Database Setup

1. Create a PostgreSQL user (if you don't already have one):
```bash
# Log into PostgreSQL as the postgres user
sudo -u postgres psql

# Create a new role
CREATE ROLE youruser WITH LOGIN PASSWORD 'yourpassword';

# Grant privileges
ALTER ROLE youruser CREATEDB;

# Exit PostgreSQL
\q
```

2. Update your `.env` file with your PostgreSQL credentials:
```
PG_USER=youruser
PG_PASSWORD=yourpassword
```

3. Run the PostgreSQL setup script:
```bash
./scripts/setup_postgres.sh
```

## Troubleshooting

### Common Issues

1. **Connection refused**
   - Make sure PostgreSQL service is running
   - Check that the port (default: 5432) is not blocked by a firewall
   - Verify host settings in `config/database.yml`

2. **Authentication failed**
   - Verify username and password in your `.env` file
   - Ensure the PostgreSQL user exists and has proper permissions

3. **Database does not exist**
   - Run `rails db:create` to create the database

## Verification

To verify your PostgreSQL setup:

```bash
rails db:version
```

This should return the current version of your database schema. If it works, your PostgreSQL connection is properly configured.

## Migrating from SQLite (if needed)

If you're migrating from SQLite to PostgreSQL:

1. Backup your SQLite data (if needed)
2. Remove the SQLite database files
3. Create the PostgreSQL database
4. Run migrations and seed data

All of this is automated in the `setup_postgres.sh` script.
