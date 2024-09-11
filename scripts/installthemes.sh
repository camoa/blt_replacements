#!/bin/bash

# This script determines the location of the custom themes folder based on the location of this script,
# iterates through all custom themes, and runs 'npm install' if 'node_modules' directory is not found.

# Set the root directory relative to the script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRUPAL_ROOT="$(dirname "$SCRIPT_DIR")/docroot"
THEMES_DIR="$DRUPAL_ROOT/themes/custom"

# Check if THEMES_DIR exists and is a directory
if [ ! -d "$THEMES_DIR" ]; then
  echo "Error: Custom themes directory does not exist: $THEMES_DIR"
  exit 1
fi

# Iterate through all subdirectories in the custom themes directory
for theme_path in "$THEMES_DIR"/*/; do
  if [ -d "$theme_path" ]; then
    theme_name=$(basename "$theme_path")
    echo "Checking theme: $theme_name"

    # Check if node_modules directory exists
    if [ ! -d "$theme_path/node_modules" ]; then
      echo "node_modules not found for theme $theme_name. Running npm install..."
      (cd "$theme_path" && npm install)
      
      # Check if npm install succeeded
      if [ $? -ne 0 ]; then
        echo "Error: npm install failed for theme $theme_name"
        exit 1
      fi

      echo "npm install completed successfully for theme $theme_name."
    else
      echo "node_modules already exists for theme $theme_name. Skipping npm install."
    fi
  fi
done

echo "Dependency installation check completed for all custom themes."
