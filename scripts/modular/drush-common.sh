#!/bin/bash

# This script runs a series of Drush commands for a given Drupal site.
# The site is specified by a URI passed as an argument to the script.

# Usage Example:
# ./drush-common.sh default
# ./drush-common.sh site1.example.com

# Verify that a site URI is provided as an argument
if [ -z "$1" ]; then
  echo "Error: No site URI provided."
  echo "Usage: $0 <site-uri>"
  exit 1
fi

SITE_URI=$1

# Set the root directory relative to the script location
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRUPAL_ROOT="$(dirname "$ROOT_DIR")/docroot"

# Check if DRUPAL_ROOT exists and is a directory
if [ ! -d "$DRUPAL_ROOT" ]; then
  echo "Error: DRUPAL_ROOT directory does not exist: $DRUPAL_ROOT"
  exit 1
fi

# Set the path to the Drush command
DRUSH_CMD="$(dirname "$ROOT_DIR")/vendor/bin/drush"

# Check if the Drush command exists and is executable
if [ ! -x "$DRUSH_CMD" ]; then
  echo "Error: Drush command not found or not executable: $DRUSH_CMD"
  exit 1
fi

# Function to run a Drush command for the provided site
run_drush_command() {
  local command=$1
  echo "Running Drush command for site: $SITE_URI: $command"
  result=$($DRUSH_CMD --root="$DRUPAL_ROOT" --uri="$SITE_URI" "$command" -y 2>&1)
  echo "This is the result $result"  # Debug statement to see the output
  # Check if the Drush command succeeded
  if [ $? -ne 0 ]; then
    echo "Error: Drush command '$command' failed for site: $SITE_URI"
    exit 1
  fi

  # Special handling for config-status
  if [ "$command" == "config-status" ]; then
    if ! printf "%s" "$result" | grep -q "No differences"; then
      echo "Error: Config status check failed for site: $SITE_URI"
      echo "Details: $result"
      exit 1
    fi
  fi
}

# Define the Drush commands to be executed for the site
DRUSH_COMMANDS=(
  "updatedb"
  "config-import"
  "config-import"
  "config-import"
  "config-status"
  "cache-rebuild"
  "deploy:hook"
)

# Run the Drush commands for the site
for command in "${DRUSH_COMMANDS[@]}"; do
  run_drush_command "$command"
done

echo "Drush commands completed for site: $SITE_URI."
