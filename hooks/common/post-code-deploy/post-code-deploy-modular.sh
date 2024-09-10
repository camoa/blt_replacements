#!/bin/bash

# This script is designed to be run automatically in Acquia Cloud after code deployment.
# It calls the ./scripts/executor.sh script, passing the [site].[env] parameter.

# Extract site and environment from environment variables
SITE_GROUP=${AH_SITE_GROUP}
ENVIRONMENT=${AH_SITE_ENVIRONMENT}

# Ensure the environment variables are set
if [ -z "$SITE_GROUP" ] || [ -z "$ENVIRONMENT" ]; then
  echo "Error: AH_SITE_GROUP or AH_SITE_ENVIRONMENT environment variables are not set."
  exit 1
fi

# Construct the site.env parameter
SITE_ENV="${SITE_GROUP}.${ENVIRONMENT}"

# Define the path to the executor script
EXECUTOR_SCRIPT="./scripts/executor.sh"

# Check if the executor script exists
if [ ! -f "$EXECUTOR_SCRIPT" ]; then
  echo "Error: Executor script not found at $EXECUTOR_SCRIPT"
  exit 1
fi

# Call the executor script with the site.env parameter
$EXECUTOR_SCRIPT pulldb "$SITE_ENV"

# Check if the executor script succeeded
if [ $? -ne 0 ]; then
  echo "Error: Executor script failed for $SITE_ENV"
  exit 1
fi

echo "Post-code-deploy script execution completed for $SITE_ENV."
