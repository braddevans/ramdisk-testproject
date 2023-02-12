# readme for ramdisk project

dump program files into persistent-data and edit the program-start.sh


or just edit the program-start.sh in persistent-data to your requirements



## notes:
uses /mnt/tmpramdiskfs as the temp ramdisk folder mount location
uses the current working directory / persistent-data as the base working folder until the ramdisk is setup and files rsynced from $pwd/persistent-data into /mnt/tmpramdiskfs
