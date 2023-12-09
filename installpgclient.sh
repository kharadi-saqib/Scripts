#!/bin/bash

# Update the package list to make sure we have the latest information
sudo apt update

# Install the PostgreSQL client
sudo apt install -y postgresql-client

# Check if the installation was successful
if [ $? -eq 0 ]; then
    echo "PostgreSQL client has been successfully installed."
else
    echo "Failed to install PostgreSQL client. Please check for errors."
fi
