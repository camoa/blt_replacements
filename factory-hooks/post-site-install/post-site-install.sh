#!/bin/bash
#
# Factory Hook: post-site-install
#
# This is an example script to perform necessary tasks using Drush
# commands when a site is created on ACSF.
# Note: This is a starting point and may need customization.
#
# Usage: post-site-install.sh sitegroup env db-role domain

# Exit immediately on error and enable verbose log output.
set -ev

# Map the script inputs to convenient names:
sitegroup="$1"
env="$2"
db_role="$3"
internal_domain="$4"

# Extract site name from the internal domain
IFS='.' read -a name <<< $internal_domain

# Drush executable
drush="/mnt/www/html/$sitegroup.$env/vendor/bin/drush"

# Execute the updates using Drush.
$drush --uri=$internal_domain updatedb -y
result=$?
[ $result -ne 0 ] && exit $result

$drush --uri=$internal_domain config-import -y
result=$?
[ $result -ne 0 ] && exit $result

$drush --uri=$internal_domain config-import -y
result=$?
[ $result -ne 0 ] && exit $result

# Check config status
config_status_output=$($drush --uri=$internal_domain config-status 2>&1)
if [[ "$config_status_output" != *"No differences"* ]]; then
  echo "Error: Config status check failed for site: $internal_domain"
  echo "Details: $config_status_output"
  exit 1
fi

$drush --uri=$internal_domain cache-rebuild
result=$?
[ $result -ne 0 ] && exit $result

$drush --uri=$internal_domain deploy:hook -y
result=$?
[ $result -ne 0 ] && exit $result

set +v

# Exit with the status of the last Drush command
exit $result
