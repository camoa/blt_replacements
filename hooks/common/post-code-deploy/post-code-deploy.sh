#!/bin/bash

set -e
set -o pipefail

# Global variables
DRUSH_CMD="/path/to/drush"
WEB_ROOT="/path/to/drupal/root"
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
        esac
        shift
    done
}

# Function to run drush commands
run_drush() {
    local cmd; cmd="$1"
    if ! output=$(${DRUSH_CMD} ${DRUSH_VERBOSITY} ${cmd} 2>&1); then
        print_error "Drush command '${cmd}' failed: ${output}"
        return 1
    fi
    printf "%s\n" "${output}"
}

# Function to update the database
update_database() {
    run_drush "updb" || return 1
}

# Function to import configuration
import_configuration() {
    run_drush "config-import -y" || return 1
}

# Function to clear caches
clear_caches() {
    run_drush "cache-rebuild" || return 1
}

# Function to check config status
check_config_status() {
    local config_status
    if ! config_status=$(run_drush "config:status"); then
        return 1
    fi

    if ! printf "%s" "$config_status" | grep -q "No differences"; then
        print_error "Configuration status check failed: differences found."
        return 1
    fi

    printf "Configuration status: No differences\n"
}

# Function to deploy Drupal
deploy_drupal() {
    printf "Starting Drupal deployment...\n"
    if ! update_database; then
        print_error "Database update failed."
        return 1
    fi

    if ! import_configuration; then
        print_error "Configuration import failed."
        return 1
    fi

    if ! check_config_status; then
        print_error "Configuration status check failed."
        return 1
    fi

    if ! clear_caches; then
        print_error "Cache clear failed."
        return 1
    fi

    printf "Drupal deployment completed successfully.\n"
}

# Main function
main() {
    parse_flags "$@"
    deploy_drupal || exit 1
}

main "$@"

