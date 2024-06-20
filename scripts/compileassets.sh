#!/usr/bin/env bash


#locate the script in the themes folder
cd docroot/themes/custom

#themes=$(find . -maxdepth 1 ! -path . -type d)
#for theme in $themes; do
#  if [  -e "$theme/install.sh" ];then
    cd uswds_hhs
      gulp compile
    cd ..
#  fi
#done
