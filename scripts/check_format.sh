#!/bin/bash

echo "🔍 Setting up format check..."

# Install dependencies
sudo apt-get update
sudo apt-get install -y python3-pip clang-format
pip install ruff # Replacing black with ruff
npm install -g eslint prettier

echo "✅ Running format checks..."

# Initialize error flag
ERRORS=0

# Check and fix Python formatting using Ruff (black + isort alternative)
echo "🔍 Checking Python formatting..."
ruff check . || ERRORS=1
echo "⚠️ Fixing Python formatting..."
ruff format .

# Check and fix JavaScript formatting
echo "🔍 Checking JavaScript formatting..."
npx eslint "**/*.js" || ERRORS=1
echo "⚠️ Fixing JavaScript formatting..."
npx eslint --fix "**/*.js"
npx prettier --write "**/*.js"

# Check and fix C++ formatting
echo "🔍 Checking C++ formatting..."
find . -name "*.cc" -o -name "*.cpp" -o -name "*.h" | xargs clang-format --dry-run --Werror || ERRORS=1
echo "⚠️ Fixing C++ formatting..."
find . -name "*.cc" -o -name "*.cpp" -o -name "*.h" | xargs clang-format -i

# Exit with failure if any checks failed
if [ "$ERRORS" -ne 0 ]; then
  echo "❌ Formatting check failed! Some files were not formatted correctly. Changes have been applied."
  exit 1
else
  echo "🎉 Formatting check passed! All files are properly formatted."
fi
