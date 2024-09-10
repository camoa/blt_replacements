# Script Automation for Drupal Sites

This repository contains a set of automation scripts designed to streamline common tasks for Drupal sites. The scripts are organized into a modular structure to facilitate ease of use and flexibility.

## Folder Structure

- `./scripts/modular`
  - `pull-db.sh`
  - `drush-common.sh`
  - `singlesite`
    - `executor.sh` (single-site version)
  - `multisite`
    - `executor.sh` (multi-site version)

## General Workflow

The main script, `executor.sh`, serves as the orchestrator, determining which specific script to run based on the provided parameters. Depending on the command, it will call one of the following scripts:

- `pull-db.sh`: Pulls the database for a site and runs a series of Drush commands.
- `drush-common.sh`: Runs a sequence of Drush commands for a site.

## Single-Site vs. Multi-Site

### Single-Site

The single-site version of `executor.sh` operates on the `default` site only. It accepts a command (`pulldb` or `drushcommon`) and an optional environment parameter:

- **Command Examples:**
  - `./executor.sh pulldb site.dev`
  - `./executor.sh drushcommon`

### Multi-Site

The multi-site version of `executor.sh` detects all sites within the `sites` directory and runs the provided command for each detected site. It accepts a command (`pulldb` or `drushcommon`) and an optional environment parameter:

- **Command Examples:**
  - `./executor.sh pulldb site.dev`
  - `./executor.sh drushcommon`

## Script Descriptions

### `executor.sh`

**Single-Site Version:**

Located in `./scripts/modular/singlesite/executor.sh`.

**Multi-Site Version:**

Located in `./scripts/modular/multisite/executor.sh`.

**Parameters:**

1. **Command**: Specifies the operation to perform (`pulldb` or `drushcommon`).
2. **Environment** (optional): Specifies the environment for the `pulldb` command (e.g., `site.dev`).

**Functionality:**

- Calls `pull-db.sh` if the command is `pulldb`.
- Calls `drush-common.sh` if the command is `drushcommon`.

### `pull-db.sh`

Located in `./scripts/modular/pull-db.sh`.

**Parameters:**

1. **Environment**: Specifies the environment (e.g., `site.dev`).
2. **Site URI** (only for multi-site version): Specifies the site to operate on.

**Functionality:**

- Pulls the database using ACLI (supports Lando and DDEV environments).
- Calls `drush-common.sh` to run a sequence of Drush commands after pulling the database.

### `drush-common.sh`

Located in `./scripts/modular/drush-common.sh`.

**Parameters:**

1. **Site URI**: Specifies the site to operate on.

**Functionality:**

- Runs a series of Drush commands for the specified site:
  1. `updatedb`
  2. `config-import` (repeated 3 times for safety)
  3. `config-status` (checks if the output contains "No differences")
  4. `cache-rebuild`

## Installation

All scripts should be placed in the `scripts` folder at the root directory of your Drupal repository for proper functioning.

