#!/usr/bin/env bash


#locate the script in the themes folder
cd docroot/themes/custom
themes=$(find .  -maxdepth 1 ! -path . -type d )
for theme in $themes; do
    if [ ! -e "$theme/node_modules" ];then
        cd $theme
        npm install
        cd ..
    fi
done
