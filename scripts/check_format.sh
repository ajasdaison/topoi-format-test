#!/bin/bash

set -eo pipefail

# Directories to check
CPP_SOURCES=(
  topoi
  app
)

PYTHON_SOURCES=(
)

SH_SOURCES=(
  scripts
)

JS_SOURCES=(
  "topoi/static/engine"
)

echo "🔍 Setting up format check..."

# Install dependencies
sudo apt-get update
sudo apt-get install -y python3-pip clang-format shfmt
pip install ruff # Replacing black with ruff
npm install -g eslint prettier

# Initialize error flag
ERRORS=0

function topoi-check-sh {
  echo "🔍 Checking Shell formatting..."
  set +e
  shfmt -w -i 2 -ci -bn -sr ${SH_SOURCES[@]}
  if [ $? -ne 0 ]; then ERRORS=1; fi
  set -e
}

function topoi-check-python {
  echo "🔍 Checking Python formatting..."
  set +e
  ruff check --fix ${PYTHON_SOURCES[@]}
  if [ $? -ne 0 ]; then ERRORS=1; fi
  echo "⚠️ Fixing Python formatting..."
  ruff format ${PYTHON_SOURCES[@]}
  set -e
}

function topoi-check-clang-format {
  echo "🔍 Checking C++ formatting..."
  set +e
  python3 run-clang-format.py --style file -r ${CPP_SOURCES[@]}
  if [ $? -ne 0 ]; then ERRORS=1; fi
  echo "⚠️ Fixing C++ formatting..."
  python3 run-clang-format.py --style file -r ${CPP_SOURCES[@]} -i
  set -e
}

function topoi-check-clang-tidy {
  echo "🔍 Running Clang-Tidy..."
  mkdir -p build
  set +e
  FILES=$(find ${CPP_SOURCES[@]} -type f -name "*.cpp" -o -name "*.h")
  
  if [ -z "$FILES" ]; then
    echo "✅ No C++ files found for Clang-Tidy."
    return 0
  fi

  for file in $FILES; do
    clang-tidy "$file" --fix --format
    if [ $? -ne 0 ]; then ERRORS=1; fi
  done

  git diff
  set -e
}

function topoi-check-javascript {
  echo "🔍 Checking JavaScript formatting..."
  set +e
  npx eslint "${JS_SOURCES[@]}/**/*.js"
  if [ $? -ne 0 ]; then ERRORS=1; fi
  echo "⚠️ Fixing JavaScript formatting..."
  npx eslint --fix "${JS_SOURCES[@]}/**/*.js"
  npx prettier --write "${JS_SOURCES[@]}/**/*.js"
  set -e
}

# Run all checks
topoi-check-sh
topoi-check-python
topoi-check-clang-format
topoi-check-clang-tidy
topoi-check-javascript

# Exit with failure if any checks failed
if [ "$ERRORS" -ne 0 ]; then
  echo "❌ Formatting check failed! Some files were not formatted correctly. Changes have been applied."
  exit 1
else
  echo "🎉 Formatting check passed! All files are properly formatted."
fi
