#!/bin/bash

set -e

echo "Installing dependencies on Ubuntu..."

# Update package lists
sudo apt-get update

# Install required packages
sudo apt-get install -y python3-pip clang-format shfmt

# Install Python and JavaScript dependencies
pip install ruff
npm install -g eslint prettier

echo "Dependencies installed successfully!"
