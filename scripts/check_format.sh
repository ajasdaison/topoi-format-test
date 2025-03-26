#!/bin/bash

set -e  # Stop only for critical failures

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

echo "Running format checks..."

# Initialize error flag
ERRORS=0

### 1. **CHECK FUNCTIONS (DO NOT MODIFY FILES)**
function topoi-check-sh {
  echo "Checking Shell formatting..."
  shfmt -d -i 2 -ci -bn -sr ${SH_SOURCES[@]} || ERRORS=1
}

function topoi-check-python {
  echo "Checking Python formatting..."
  ruff check ${PYTHON_SOURCES[@]} || ERRORS=1
}

function topoi-check-clang-format {
  echo "Checking C++ formatting..."
  python3 run-clang-format.py --style file -r ${CPP_SOURCES[@]} || ERRORS=1
}

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

function topoi-check-javascript {
  echo "Checking JavaScript formatting..."
  npx eslint "${JS_SOURCES[@]}/**/*.js" || ERRORS=1
}

# Run all checks
topoi-check-sh
topoi-check-python
topoi-check-clang-format
topoi-check-clang-tidy
topoi-check-javascript

# If errors were found, show a git diff to suggest fixes
if [ "$ERRORS" -ne 0 ]; then
  echo "Issues detected. Showing suggested fixes..."
  
  # Run formatting commands **only for diff generation, without modifying files**
  shfmt -d -i 2 -ci -bn -sr ${SH_SOURCES[@]} &> /dev/null
  ruff format --diff ${PYTHON_SOURCES[@]} &> /dev/null
  python3 run-clang-format.py --style file -r ${CPP_SOURCES[@]} --dry-run &> /dev/null
  npx prettier --check "${JS_SOURCES[@]}/**/*.js" &> /dev/null

  # Display git diff (suggests changes but does NOT modify files)
  git diff

  echo "Formatting issues found. Please run the appropriate format commands to fix them."
  exit 1
else
  echo "All checks passed. No changes needed."
fi
