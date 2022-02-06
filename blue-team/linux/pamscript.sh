#!/bin/bash
# Create backups for the modules and configuration files 
mkdir -p /var/backups/
cp -r /etc/pam* /var/backups/
cp -r /lib/security* /var/backup/
cp -r /etc /var/backup/

chattr +i # TWO THINGS, make files immutable 
# etc
# modules
chattr +i -RV /var/backups/*

find / -name ‘pam*’ > pam_locs.txt
