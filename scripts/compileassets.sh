#!/bin/bash

# This script iterates through each custom theme in the 'themes/custom' directory
# and runs a build command. If a theme folder name contains 'uswds', it runs 'gulp compile'
# instead of 'gulp build'. Users should modify the build commands to match their 
# specific build tools if needed.

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
    echo "Building theme: $theme_name"

    # Determine the build command based on theme name
    if [[ "$theme_name" == *"uswds"* ]]; then
      echo "Custom build command for USWDS theme: $theme_name"
      (cd "$theme_path" && gulp compile)
    else
      (cd "$theme_path" && gulp build)
    fi

    # Check if the build command succeeded
    if [ $? -ne 0 ]; then
      echo "Error: Build command failed for theme $theme_name"
      exit 1
    fi

    echo "Build completed successfully for theme $theme_name."
  fi
done

echo "Theme building process completed for all custom themes."
