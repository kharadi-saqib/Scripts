#!/bin/bash

# Function to display errors and exit
check_error() {
  if [ $? -ne 0 ]; then
    echo "Error: $1." >&2
    exit 1
  fi
}

# 0. Update and upgrade installed packages
echo "0. Updating and upgrading installed packages"
sudo apt-get update -y
check_error "Error updating package lists"

sudo apt-get upgrade -y
check_error "Error upgrading installed packages"

# 1. Install PostgreSQL
echo "1. Installing PostgreSQL"
sudo apt-get install postgresql postgresql-contrib -y
check_error "Error installing PostgreSQL"

sudo systemctl start postgresql
check_error "Error starting PostgreSQL"

sudo systemctl enable postgresql
check_error "Error enabling PostgreSQL"

echo "PostgreSQL installation completed successfully."

# 2. Add a new user
echo "2. Adding a new PostgreSQL user"
pg_conf_dir='/etc/postgresql/14/main'  # Replace <version> with your PostgreSQL version, e.g., 12
USERNAME="coderize"
PASSWORD="coderize"

sudo -u postgres psql -c "CREATE ROLE $USERNAME WITH LOGIN SUPERUSER PASSWORD '$PASSWORD';"
check_error "Error creating PostgreSQL user"

echo "local   all             $USERNAME                                    trust" | sudo tee -a "$pg_conf_dir/pg_hba.conf"
check_error "Error adding pg_hba.conf entry"

sudo service postgresql restart
check_error "Error restarting PostgreSQL"

echo "User '$USERNAME' created with the hardcoded password."

# 3. Update PostgreSQL configurations
echo "3. Updating PostgreSQL configurations"
postgresql_conf="/etc/postgresql/14/main/postgresql.conf"
pg_hba_conf="/etc/postgresql/14/main/pg_hba.conf"

if sudo service postgresql status >/dev/null 2>&1; then
  echo "Stopping PostgreSQL service"
  sudo service postgresql stop
  check_error "Error stopping PostgreSQL service"
fi

# Backup the original configurations
sudo cp "$postgresql_conf" "$postgresql_conf.bak"
sudo cp "$pg_hba_conf" "$pg_hba_conf.bak"

# Update postgresql.conf to allow all addresses
echo "Updating postgresql.conf to allow all addresses"
sudo sed -i "s/^#listen_addresses = 'localhost'/listen_addresses = '*'/g" "$postgresql_conf"
check_error "Error updating postgresql.conf"

# Update pg_hba.conf to trust all local connections
echo "Updating pg_hba.conf to trust all local connections"
sudo sed -i "s/^local\s\+all\s\+all\s\+peer/local   all             all                                     trust/g" "$pg_hba_conf"
check_error "Error updating pg_hba.conf"

echo "Starting PostgreSQL service"
sudo service postgresql start
check_error "Error starting PostgreSQL service"

echo "PostgreSQL configurations updated successfully."

echo "PostgreSQL setup completed successfully."
