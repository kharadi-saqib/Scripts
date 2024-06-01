#!/bin/bash

# Step 1: Download Jenkins key
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

# Output
echo "Jenkins key downloaded successfully."

# Step 2: Add Jenkins apt repository entry
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Output
echo "Jenkins apt repository entry added."

# Step 3: Update local package index
sudo apt-get update

# Output
echo "Local package index updated successfully."

# Step 4: Install required packages
sudo apt-get install -y fontconfig openjdk-17-jre

# Output
echo "Required packages installed successfully."

# Step 5: Install Jenkins
sudo apt-get install -y jenkins

# Output
echo "Jenkins installed successfully."
