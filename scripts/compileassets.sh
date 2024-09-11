#!/usr/bin/env bash
set -x

# Locate the script in the themes folder.
cd docroot/themes/custom

themes=$(find . -maxdepth 1 ! -path . -type d)
for theme in $themes; do
  if [ ! -e "$theme/css" ]; then
    cd "$theme"
    #An example of a theme that uses a different command, could be extended with eleseif
    if [[ "$theme" == *"uswds"* ]]; then
      gulp compile
    else
      gulp build
    fi
    cd ..
  fi
done
