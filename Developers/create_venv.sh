#!/bin/bash

# Check if virtualenv package is installed
if ! command -v virtualenv &> /dev/null; then
    echo "virtualenv is not installed. Installing..."
    pip install virtualenv
fi

# Directory to create virtual environment
venv_dir="$(basename "$(pwd)")_venv"

# Create virtual environment
if [ ! -d "$venv_dir" ]; then
    virtualenv "$venv_dir"
    echo "Virtual environment created successfully in $venv_dir"
else
    echo "Virtual environment already exists in $venv_dir"
fi
