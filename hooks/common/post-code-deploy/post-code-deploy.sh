#!/bin/bash

set -e
set -o pipefail

# Global variables
DRUSH_CMD="/path/to/drush"
WEB_ROOT="/path/to/drupal/root"
SITES_DIR="${WEB_ROOT}/sites"
DRUSH_VERBOSITY=""

# Function to print error messages
print_error() {
    printf "ERROR: %s\n" "$1" >&2
}

# Function to parse verbosity flags
parse_flags() {
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -v|-vv|-vvv)
                DRUSH_VERBOSITY="$1"
                ;;
            *)
                print_error "Invalid flag: $1"
                exit 1
                ;;
        esac
        shift
    done
}

# Function to run drush commands
run_drush() {
    local cmd="$1"
    local site_alias="$2"
    if ! output=$(${DRUSH_CMD} ${DRUSH_VERBOSITY} ${site_alias} ${cmd} 2>&1); then
        print_error "Drush command '${cmd}' for site '${site_alias}' failed: ${output}"
        return 1
    fi
    printf "%s\n" "${output}"
}

# Function to update the database
update_database() {
    local site_alias="$1"
    run_drush "updb" "${site_alias}" || return 1
}

# Function to import configuration
import_configuration() {
    local site_alias="$1"
    local retries=3
    local attempt=1
    while [[ $attempt -le $retries ]]; do
        printf "Importing configuration for site ${site_alias} (attempt %d/%d)...\n" "$attempt" "$retries"
        if run_drush "config-import -y" "${site_alias}"; then
            printf "Configuration import for site ${site_alias} succeeded on attempt %d\n" "$attempt"
            return 0
        fi
        printf "Configuration import for site ${site_alias} failed on attempt %d\n" "$attempt"
        attempt=$((attempt + 1))
    done
    print_error "Configuration import for site ${site_alias} failed after $retries attempts."
    return 1
}

# Function to clear caches
clear_caches() {
    local site_alias="$1"
    run_drush "cache-rebuild" "${site_alias}" || return 1
}

# Function to check config status
check_config_status() {
    local site_alias="$1"
    local config_status
    if ! config_status=$(run_drush "config:status" "${site_alias}"); then
        return 1
    fi

    if ! printf "%s" "$config_status" | grep -q "No differences"; then
        print_error "Configuration status check for site ${site_alias} failed: differences found."
        return 1
    fi

    printf "Configuration status for site ${site_alias}: No differences\n"
}

# Function to deploy Drupal
deploy_drupal() {
    local site_dir="$1"
    local site_alias="@${site_dir}"

    printf "Starting Drupal deployment for site ${site_alias}...\n"
    if ! update_database "${site_alias}"; then
        print_error "Database update for site ${site_alias} failed."
        return 1
    fi

    if ! import_configuration "${site_alias}"; then
        print_error "Configuration import for site ${site_alias} failed."
        return 1
    fi

    if ! check_config_status "${site_alias}"; then
        print_error "Configuration status check for site ${site_alias} failed."
        return 1
    fi

    if ! clear_caches "${site_alias}"; then
        print_error "Cache clear for site ${site_alias} failed."
        return 1
    fi

    printf "Drupal deployment for site ${site_alias} completed successfully.\n"
}

# Main function
main() {
    parse_flags "$@"

    for site_dir in $(find "${SITES_DIR}" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;); do
        if [ "$site_dir" != "default" ]; then
            deploy_drupal "$site_dir" || exit 1
        fi
    done
}

main "$@"


