#!/bin/bash

# PostgreSQL pg_hba.conf file path
PG_HBA_CONF="/etc/postgresql/14/main/pg_hba.conf"

# IP address to allow for replication
REPLICATION_IP="52.66.205.238/32"

# PostgreSQL configuration line to add
CONFIG_LINE="host    replication     replicator      $REPLICATION_IP        md5"

# Add the configuration line to pg_hba.conf
echo "$CONFIG_LINE" | sudo tee -a "$PG_HBA_CONF" > /dev/null

# Check if the line was successfully added
if [ $? -eq 0 ]; then
  echo "Configuration line added to pg_hba.conf successfully."
else
  echo "Error adding configuration line to pg_hba.conf."
fi
