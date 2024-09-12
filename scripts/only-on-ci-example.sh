#!/bin/bash

# Check if the script is running in GitHub Actions
if [ "$GITHUB_ACTIONS" = "true" ]; then
  ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

  echo "Running frontend-reqs script with Composer..."
  (cd "$ROOT_DIR" && composer run-script frontend-reqs)
  if [ $? -ne 0 ]; then
    echo "Error: frontend-reqs script failed."
    exit 1
  fi

  echo "Running frontend-assets script with Composer..."
  (cd "$ROOT_DIR" && composer run-script frontend-assets)
  if [ $? -ne 0 ]; then
    echo "Error: frontend-assets script failed."
    exit 1
  fi

  echo "Theme dependencies installed and assets compiled successfully."

fi

# Additional comments:
# You can wrap your script logic within an 'if' condition for other CI/CD systems by checking the respective environment variables.
# Here are some common environment variables for various CI/CD systems:

# Tugboat CI:
#   Variable: TUGBOAT_SERVICE
#   Example: [ -n "$TUGBOAT_SERVICE" ] && echo "Script is running in Tugboat CI."

# Azure Pipelines:
#   Variable: AGENT_ID
#   Example: [ -n "$AGENT_ID" ] && echo "Script is running in Azure Pipelines."

# GitLab CI:
#   Variable: GITLAB_CI
#   Example: [ "$GITLAB_CI" = "true" ] && echo "Script is running in GitLab CI."

# CircleCI:
#   Variable: CIRCLECI
#   Example: [ "$CIRCLECI" = "true" ] && echo "Script is running in CircleCI."

# Travis CI:
#   Variable: TRAVIS
#   Example: [ "$TRAVIS" = "true" ] && echo "Script is running in Travis CI."

# Jenkins:
#   Variable: JENKINS_URL
#   Example: [ -n "$JENKINS_URL" ] && echo "Script is running in Jenkins."

# Bitbucket Pipelines:
#   Variable: BITBUCKET_BUILD_NUMBER
#   Example: [ -n "$BITBUCKET_BUILD_NUMBER" ] && echo "Script is running in Bitbucket Pipelines."
