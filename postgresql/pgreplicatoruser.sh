#!/bin/bash

# PostgreSQL connection parameters
DB_USER="coderize"
DB_NAME="postgres"
DB_HOST="localhost"
DB_PORT="5432"

# SQL statement to create the user
SQL_STATEMENT="CREATE USER replicator REPLICATION LOGIN CONNECTION LIMIT 3 ENCRYPTED PASSWORD 'replicator';"

# Execute the SQL statement using psql
result=$(psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -p "$DB_PORT" -c "$SQL_STATEMENT" 2>&1)

# Check the result
if [ $? -eq 0 ]; then
  echo "User 'replicator' created successfully."
else
  echo "Error creating user 'replicator': $result"
fi
