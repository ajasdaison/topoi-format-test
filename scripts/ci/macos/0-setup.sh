#!/bin/bash

set -e

echo "Installing dependencies on macOS..."

# Install required packages using Homebrew
brew update
brew install python3 clang-format shfmt npm

# Install Python and JavaScript dependencies
pip3 install ruff
npm install -g eslint prettier

echo "Dependencies installed successfully!"
