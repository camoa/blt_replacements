#!/bin/bash
#
# Factory Hook: db-update
#
# This is an example script to perform necessary tasks using Drush
# commands during a database update on ACSF.
# Note: This is a starting point and may need customization.
#
# Usage: db-update.sh sitegroup env db-role domain custom-arg

# Exit immediately on error and enable verbose log output.
set -ev

# Map the script inputs to convenient names:
sitegroup="$1"
env="$2"
db_role="$3"
domain="$4"

# Get the internal domain name based on the site, environment, and db role arguments
uri=$(/usr/bin/env php /mnt/www/html/$sitegroup.$env/hooks/acquia/uri.php $sitegroup $env $db_role)
IFS='.' read -a name <<< "$uri"

# Drush executable
drush="/mnt/www/html/$sitegroup.$env/vendor/bin/drush"

echo "Running Drush deploy tasks on $uri domain in $env environment on the $sitegroup subscription."

# Execute the updates using Drush.
$drush --uri=$domain/ updatedb -y
result=$?
[ $result -ne 0 ] && exit $result

$drush --uri=$domain/ config-import -y
result=$?
[ $result -ne 0 ] && exit $result

$drush --uri=$domain/ config-import -y
result=$?
[ $result -ne 0 ] && exit $result

# Check config status
config_status_output=$($drush --uri=$domain/ config-status 2>&1)
if [[ "$config_status_output" != *"No differences"* ]]; then
  echo "Error: Config status check failed for site: $domain"
  echo "Details: $config_status_output"
  exit 1
fi

$drush --uri=$domain/ cache-rebuild
result=$?
[ $result -ne 0 ] && exit $result

$drush --uri=$domain/ deploy:hook -y
result=$?
[ $result -ne 0 ] && exit $result

# Clean up the Drush cache directory
echo "Removing temporary Drush cache files."
# Add any necessary cleanup commands here, for example:
# rm -rf /tmp/drush*

set +v

# Exit with the status of the last Drush command
exit $result
