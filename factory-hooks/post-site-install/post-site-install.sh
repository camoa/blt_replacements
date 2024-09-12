#!/bin/bash
#
# Factory Hook: post-site-install
#
# This is necessary to replicate the BLT drupal:install tasks using Drush
# commands when a site is created on ACSF.
#
# Usage: post-site-install.sh sitegroup env db-role domain

# Exit immediately on error and enable verbose log output.
set -ev

# Map the script inputs to convenient names:
# Acquia Hosting sitegroup (application) and environment.
sitegroup="$1"
env="$2"
# Database role. This is a truly unique identifier for an ACSF site and is e.g.
# part of the public files path.
db_role="$3"
# Internal (Acquia managed) domain name of the website. (No public domain name
# is assigned yet, immediately after installation.) The first part is a name
# that is unique per installed site. A small but significant difference with
# $db_role: if a site gets deleted and reinstalled with the same name, it gets
# a different $db_role.
internal_domain="$4"
# To get only the site name in ${name[0]}:
IFS='.' read -a name <<< $internal_domain

# Drush executable:
drush="/mnt/www/html/$sitegroup.$env/vendor/bin/drush"

# Execute the updates using Drush.
$drush --uri=$internal_domain updatedb -y
result=$?
# Exit immediately if a command fails
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
