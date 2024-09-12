#!/bin/bash

# This script executes a specified command for the 'default' Drupal site.
# Supported commands are "pulldb" and "drushcommon". 
# An optional environment parameter can be passed for the pulldb command.

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
SITE_URI="default"

# Function to run the specified command
run_command() {
  echo "Executing $COMMAND for site: $SITE_URI"
  
  if [ "$COMMAND" == "pulldb" ]; then
    if [ -n "$ENVIRONMENT" ]; then
      ./pull-db.sh "$ENVIRONMENT" "$SITE_URI"
    else
      ./pull-db.sh "$SITE_URI"
    fi
  elif [ "$COMMAND" == "drushcommon" ]; then
    ./drush-common.sh "$SITE_URI"
  else
    echo "Error: Unknown command '$COMMAND'."
    exit 1
  fi

  if [ $? -ne 0 ]; then
    echo "Error: $COMMAND for $SITE_URI failed"
    exit 1
  fi
}

# Run the specified command for the 'default' site
run_command

echo "$COMMAND completed for site: $SITE_URI."
