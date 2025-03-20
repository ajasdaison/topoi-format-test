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
  tools
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
  shfmt -w -i 2 -ci -bn -sr ${SH_SOURCES[@]}
}

function topoi-check-python {
  echo "🔍 Checking Python formatting..."
  ruff check --fix ${PYTHON_SOURCES[@]} || ERRORS=1
  echo "⚠️ Fixing Python formatting..."
  ruff format ${PYTHON_SOURCES[@]}
}

function topoi-check-clang-format {
  echo "🔍 Checking C++ formatting..."
  python3 tools/run-clang-format.py --style file -r ${CPP_SOURCES[@]} || ERRORS=1
  echo "⚠️ Fixing C++ formatting..."
  python3 tools/run-clang-format.py --style file -r ${CPP_SOURCES[@]} -i
}

function topoi-check-clang-tidy {
  echo "🔍 Running Clang-Tidy..."
  mkdir -p build
  ARGS=(
    -DCMAKE_EXPORT_COMPILE_COMMANDS=on
    -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++
  )

  cmake -B build -S . "${ARGS[@]}"
  set +e
  FILES=$(find ${CPP_SOURCES[@]} -type f)
  run-clang-tidy -export-fixes build/clang-tidy.topoi.yml -fix -format -p build -header-filter="$PWD/src" ${FILES[@]}
  CHECK_STATUS=$?
  git diff
  set -e
  return $CHECK_STATUS
}

function topoi-check-javascript {
  echo "🔍 Checking JavaScript formatting..."
  npx eslint "${JS_SOURCES[@]}/**/*.js" || ERRORS=1
  echo "⚠️ Fixing JavaScript formatting..."
  npx eslint --fix "${JS_SOURCES[@]}/**/*.js"
  npx prettier --write "${JS_SOURCES[@]}/**/*.js"
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
