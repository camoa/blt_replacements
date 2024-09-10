#!/bin/bash

# This script pulls the database for a given Drupal site using ACLI
# and then runs a sequence of Drush commands on the site.

# Usage Example:
# ./pull-db.sh site.dev default
# ./pull-db.sh site.dev site1.example.com

# Verify that the environment variable and site URI are provided
if [ -z "$2" ]; then
  echo "Error: Not enough arguments provided."
  echo "Usage: $0 <environment> <site-uri>"
  exit 1
fi

ENVIRONMENT=$1
SITE_URI=$2

# Set the root directory relative to the script location
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRUPAL_ROOT="$(dirname "$ROOT_DIR")/docroot"

# Check if DRUPAL_ROOT exists and is a directory
if [ ! -d "$DRUPAL_ROOT" ]; then
  echo "Error: DRUPAL_ROOT directory does not exist: $DRUPAL_ROOT"
  exit 1
fi

# Detect if Lando is configured
if [ -f "$DRUPAL_ROOT/.lando.yml" ]; then
  IS_LANDO=true
else
  IS_LANDO=false
fi

# Detect if DDEV is configured
if [ -d "$DRUPAL_ROOT/.ddev" ]; then
  IS_DDEV=true
else
  IS_DDEV=false
fi

# Run ACLI command to pull the database for the site
echo "Running ACLI command to pull the database for site: $SITE_URI"
if [ "$IS_LANDO" = true ]; then
  lando acli pull:db "$ENVIRONMENT" "$SITE_URI"
elif [ "$IS_DDEV" = true ]; then
  ddev exec acli pull:db "$ENVIRONMENT" "$SITE_URI"
else
  acli pull:db "$ENVIRONMENT" "$SITE_URI"
fi

# Check if the ACLI command succeeded
if [ $? -ne 0 ]; then
  echo "Error: ACLI command to pull the database for $SITE_URI at environment $ENVIRONMENT failed"
  exit 1
fi

# Call the drush-common.sh script to run Drush commands for the site
./drush-common.sh "$SITE_URI"
if [ $? -ne 0 ]; then
  echo "Error: Drush commands for $SITE_URI failed"
  exit 1
fi

echo "ACLI and Drush commands completed for site: $SITE_URI."
