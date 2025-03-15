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

# Check Python formatting using Ruff (black + isort)
ruff format --check . || ERRORS=1
if [ "$ERRORS" -ne 0 ]; then
  echo "⚠️ Fixing Python formatting..."
  ruff format .
fi

# Check JavaScript formatting
npx eslint "**/*.js" || ERRORS=1
npx prettier --check "**/*.js" || ERRORS=1

if [ "$ERRORS" -ne 0 ]; then
  echo "⚠️ Fixing JavaScript formatting..."
  npx eslint --fix "**/*.js"
  npx prettier --write "**/*.js"
fi

# Check C++ formatting
find . -name "*.cc" -o -name "*.cpp" -o -name "*.h" | xargs clang-format --dry-run --Werror || ERRORS=1

if [ "$ERRORS" -ne 0 ]; then
  echo "⚠️ Fixing C++ formatting..."
  find . -name "*.cc" -o -name "*.cpp" -o -name "*.h" | xargs clang-format -i
fi

# Exit with failure if any checks failed before fixing
if [ "$ERRORS" -ne 0 ]; then
  echo "❌ Formatting check failed! Some files were not formatted correctly. Changes have been applied."
  exit 1
else
  echo "🎉 Formatting check passed!"
fi
