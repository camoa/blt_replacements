#!/bin/bash

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

# Function to run Drush command for a given multisite
run_drush_for_multisite() {
  local site_path=$1
  local command=$2
  echo "Running Drush command for site: $site_path: $command"
  result=$($DRUSH_CMD --root="$DRUPAL_ROOT" --uri="$site_path" "$command" -y 2>&1)
  echo "$result"  # Debug statement to see the output
  # Check if the Drush command succeeded
  if [ $? -ne 0 ]; then
    echo "Error: Drush command '$command' failed for site: $site_path"
    exit 1
  fi

  # Special handling for config-status
  if [ "$command" == "config-status" ]; then
    if ! printf "%s" "$result" | grep -q "No differences"; then
      echo "Error: Config status check failed for site: $site_path"
      echo "Details: $result"
      exit 1
    fi
  fi
}

# Detect multisites by looking for settings.php files
MULTISITE_URIS=()

# Always ensure 'default' site is included
if [ -f "$DRUPAL_ROOT/sites/default/settings.php" ]; then
  MULTISITE_URIS+=("default")
else
  echo "Error: Default site settings.php not found in $DRUPAL_ROOT/sites/default"
  exit 1
fi

for site_path in "$DRUPAL_ROOT/sites"/*/; do
  if [ -f "${site_path}settings.php" ]; then
    site_uri=$(basename "$site_path")
    # Exclude 'default' as it's already added
    if [ "$site_uri" != "default" ]; then
      MULTISITE_URIS+=("$site_uri")
    fi
  fi
done

# Define the Drush commands to be executed for each multisite
DRUSH_COMMANDS=(
  "updatedb"
  "config-import"
  "config-import"
  "config-import"
  "config-status"
  "cache-rebuild"
  "deploy:hook"
)

# Run the Drush commands for each detected multisite
for site in "${MULTISITE_URIS[@]}"; do
  for command in "${DRUSH_COMMANDS[@]}"; do
    run_drush_for_multisite "$site" "$command"
  done
done

echo "Drush commands completed for all sites."
