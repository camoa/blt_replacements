# Example scripts to replace BLT functionalities

This repository contains a set of automation scripts designed to streamline common tasks for Drupal sites. The scripts are organized into a modular structure to facilitate ease of use and flexibility.

## Folder Structure

- `./scripts`
  - `installthemes.sh` Runs npm install in all themes inside `themes/custom`
  - `compileassets.sh` Compiles assets on all themes inside `themes/custom`
  - `drush-cmd-in-all-sites.sh` Script that runs updb and cim in all sites inside the `sites` folder. Could replace post-code-deploy.
  - `./scripts/modular`
    - `pull-db.sh`
    - `drush-common.sh`
    - `singlesite`
      - `executor.sh` (single-site version)
    - `multisite`
      - `executor.sh` (multi-site version)


## Installation

All scripts should be placed in the `scripts` folder at the root directory of your Drupal repository for proper functioning.

## Modular scripts for pulling DB andor running Drush commands: Updb and CIM

These scripts can be used to pull Db and run the necessary UPDB and CIM commands or just the Drush commands.

Read modular/README.md

