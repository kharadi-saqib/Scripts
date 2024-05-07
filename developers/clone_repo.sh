#!/bin/bash

# Prompt user for Git repository URL
read -p "Enter the Git repository URL: " repo_url

# Prompt user for destination directory
read -p "Enter the destination directory (or press Enter to use the current directory): " dest_dir

# If the destination directory is not provided, use the current directory
if [ -z "$dest_dir" ]; then
  dest_dir="."
fi

# Check if the destination directory is empty
if [ "$(ls -A "$dest_dir")" ]; then
  echo "Error: The destination directory is not empty. Please choose an empty directory or provide a new directory name."
else
  # Clone the Git repository
  git clone "$repo_url" "$dest_dir"

  # Check if the cloning was successful
  if [ $? -eq 0 ]; then
    echo "Repository cloned successfully to $dest_dir."
  else
    echo "Failed to clone repository. Please check the Git repository URL and try again."
  fi
fi
    