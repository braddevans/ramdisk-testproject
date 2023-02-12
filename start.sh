#!/usr/bin/env bash

source ./config.sh

# this check is for using mounts
# shellcheck disable=SC2071
if [[ $EUID > 0 ]]; then
  echo "Please run as root/sudo"
  exit 1
fi

if [ ! -d "$PWD"/logs/ ]; then
  echo "logs directory: ($PWD/logs/) does not exist creating..."
  mkdir -p "$PWD/logs/"
  mkdir -p "$PWD/logs/childprocess1/"
fi

#####
# Start of script
#####

# does the ramdisk mount folder exist?
echo "checking if ramdisk mount folder exists..." >> ./logs/general.log
if [ ! -d /mnt/tmpramdiskfs ]; then
  echo "ramdisk directory: (/mnt/tmpramdiskfs) does not exist creating..." >> ./logs/general.log
  mkdir /mnt/tmpramdiskfs
fi

echo "checking if ramdisk is mounted..."
df /mnt/tmpramdiskfs | grep -q /mnt/tmpramdiskfs && ramdisk_mounted=1 || echo "Not mounted"
if [ $ramdisk_mounted -eq 0 ]; then
  echo "RAMDISK Filesystem is Not MOUNTED" >> ./logs/general.log
  echo "Trying to Mount /mnt/tmpramdiskfs with size: $(echo $gb_size) GB"
  echo "Trying to Mount /mnt/tmpramdiskfs with size: $(echo $gb_size) GB" >> ./logs/general.log
  mount -t tmpfs -o size=$(echo $ramdisk_size)m tmpfs /mnt/tmpramdiskfs
  echo "RAMDISK IS NOW MOUNTED" >> ./logs/general.log
  ramdisk_mounted=1
else
  echo "RAMDISK IS MOUNTED" >> ./logs/general.log
fi

# copying persistent files from persistent-data to ramdisk
echo "copying persistent files from persistent-data to ramdisk..."
echo "copying persistent files from persistent-data to ramdisk..." >> ./logs/general.log
rsync -auv "$ramdisk_commit_location" /mnt/tmpramdiskfs/ >> ./logs/ramdisk_rsync.log

# start background sync for persistent data
bash ./scripts/background_rsync.sh & childPID=$!;


#####
# Program here
#####

cd /mnt/tmpramdiskfs && echo "Process Working Directory Now in $PWD"
cd /mnt/tmpramdiskfs && echo "Process Working Directory Now in $PWD" >> "$o_pwd"/logs/general.log

##########################################
# program command block
##########################################

echo "Executing Program in: $PWD";
bash "$PWD"/program-start.sh & programPID=$!;
wait $programPID;


##########################################



####
# Cleanup / End of script
###

# kill the child background process
kill -9 $childPID

echo "End of script reached cleaning up..."
echo "End of script reached cleaning up..." >> "$o_pwd"/logs/general.log
echo "saving ramdisk contents to disk..."
rsync -auv /mnt/tmpramdiskfs/ "$ramdisk_commit_location" >> "$o_pwd"/logs/ramdisk_rsync.log

echo "removing ramdisk contents..."
echo "removing ramdisk contents..." >> "$o_pwd"/logs/general.log
rm -Rvf /mnt/tmpramdiskfs/*
rm -Rvf /mnt/tmpramdiskfs/.* 2> /dev/null


echo "RAMDISK IS Un-Mounting waiting 5 seconds before proceding..."
echo "RAMDISK IS Un-Mounting waiting 5 seconds before proceding..." >> "$o_pwd"/logs/general.log
sleep 7
umount -l /mnt/tmpramdiskfs
echo "RAMDISK IS UN-MOUNTED"
echo "RAMDISK IS UN-MOUNTED" >> "$o_pwd"/logs/general.log