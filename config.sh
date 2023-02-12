#!/usr/bin/env bash

# variables
ramdisk_mounted=0
ramdisk_size=11992
ramdisk_commit_location="$PWD/persistent-data/"
gb_size=$(echo $(($ramdisk_size / 1024)))
o_pwd=$PWD