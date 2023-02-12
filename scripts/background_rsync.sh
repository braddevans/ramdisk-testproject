#!/usr/bin/env bash

source ./config.sh

while true
do
  echo "Child Process 1 Rsync Background commit to persistent disk." >> ./logs/childprocess1/general.log;
  rsync -auv /mnt/tmpramdiskfs/ "$ramdisk_commit_location" >> ./logs/childprocess1/ramdisk_rsync.log & rdPID=$!;
  wait $rdPID;
  echo "Child Process 1 loop at time: $(date +%T) eith exit status: $? rdPID: $rdPID" >> ./logs/childprocess1/general.log;
  sleep 10m;
done