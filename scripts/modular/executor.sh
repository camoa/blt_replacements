#!/bin/bash

# This script detects all multisites in a Drupal installation and executes
# a specified command on each site. Supported commands are "pulldb" and 
# "drushcommon". An optional environment parameter can be passed for certain commands.

# Usage Examples:
# ./executor.sh pulldb site.dev
# ./executor.sh drushcommon

# Verify that the command is provided
if [ -z "$1" ]; then
  echo "Error: No command provided."
  echo "Usage: $0 <command> [environment]"
  exit 1
fi

COMMAND=$1
ENVIRONMENT=$2

# Get the root directory relative to the script location
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRUPAL_ROOT="$(dirname "$ROOT_DIR")/docroot"

# Check if DRUPAL_ROOT exists and is a directory
if [ ! -d "$DRUPAL_ROOT" ]; then
  echo "Error: DRUPAL_ROOT directory does not exist: $DRUPAL_ROOT"
  exit 1
fi

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

# Run the specified command for each detected multisite
for site in "${MULTISITE_URIS[@]}"; do
  echo "Executing $COMMAND for site: $site"
  
  if [ "$COMMAND" == "pulldb" ]; then
    if [ -n "$ENVIRONMENT" ]; then
      ./pull-db.sh "$ENVIRONMENT" "$site"
    else
      ./pull-db.sh "$site"
    fi
  elif [ "$COMMAND" == "drushcommon" ]; then
    ./drush-common.sh "$site"
  else
    echo "Error: Unknown command '$COMMAND'."
    exit 1
  fi

  if [ $? -ne 0 ]; then
    echo "Error: $COMMAND for $site failed"
    exit 1
  fi
done

echo "$COMMAND completed for all sites."
