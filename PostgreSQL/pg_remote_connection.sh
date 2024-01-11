#!/bin/bash

# Specify the PostgreSQL data directory
PG_DATA_DIR="/etc/postgresql/14/main"

# Specify the IP address, user, database, and authentication method
IP_ADDRESS="172.31.43.111/32"
DATABASE="all"
USER="coderize"
AUTH_METHOD="md5"

# Step 1: Edit pg_hba.conf
echo "Editing pg_hba.conf..."
echo "host    $DATABASE    $USER    $IP_ADDRESS    $AUTH_METHOD" | sudo tee -a "$PG_DATA_DIR/pg_hba.conf"

# Step 2: Reload PostgreSQL
echo "Reloading PostgreSQL..."
sudo systemctl reload postgresql

echo "Configuration updated successfully."
