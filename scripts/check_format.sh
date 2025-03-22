#!/bin/bash

set -e # Stop only for critical failures

echo "Setting up format check..."

# Detect OS and run the appropriate setup script
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  bash scripts/ci/ubuntu/0-setup.sh
elif [[ "$OSTYPE" == "darwin"* ]]; then
  bash scripts/ci/macos/0-setup.sh
else
  echo "⚠️ Unsupported OS: $OSTYPE"
  exit 1
fi

# Directories to check
CPP_SOURCES=(
  topoi
  engine/app
)

PYTHON_SOURCES=(
)

SH_SOURCES=(
  scripts
)

JS_SOURCES=(
  "topoi/static/engine"
)

echo "Setting up format check..."

# Initialize error flag
ERRORS=0

# Function to check shell script formatting
function topoi-check-sh {
  echo "Checking Shell formatting..."
  shfmt -d -i 2 -ci -bn -sr ${SH_SOURCES[@]} || ERRORS=1
}

# Function to check Python formatting
function topoi-check-python {
  echo "Checking Python formatting..."
  ruff check ${PYTHON_SOURCES[@]} || ERRORS=1
}

# Function to check C++ formatting
function topoi-check-clang-format {
  echo "Checking C++ formatting..."
  python3 run-clang-format.py --style file -r ${CPP_SOURCES[@]} || ERRORS=1
}

# Function to check C++ static analysis
function topoi-check-clang-tidy {
  echo "Running Clang-Tidy..."
  mkdir -p build
  FILES=$(find ${CPP_SOURCES[@]} -type f -name "*.cpp" -o -name "*.h")

  if [ -z "$FILES" ]; then
    echo "No C++ files found for Clang-Tidy."
    return
  fi

  for file in $FILES; do
    clang-tidy "$file" || ERRORS=1
  done
}

# Function to check JavaScript formatting
function topoi-check-javascript {
  echo "Checking JavaScript formatting..."
  npx eslint "${JS_SOURCES[@]}/**/*.js" || ERRORS=1
}

# Run all checks (continue even if one fails)
topoi-check-sh
topoi-check-python
topoi-check-clang-format
topoi-check-clang-tidy
topoi-check-javascript

# Show overall status
if [ "$ERRORS" -ne 0 ]; then
  echo "Formatting check completed with issues. Review the errors above."
  exit 1
else
  echo "All checks passed."
fi
