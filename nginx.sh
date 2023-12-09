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

# 1. Install Nginx
echo "1. Installing Nginx"
sudo apt-get install nginx -y
check_error "Error installing Nginx"

sudo systemctl start nginx
check_error "Error starting Nginx"

sudo systemctl enable nginx
check_error "Error enabling Nginx"