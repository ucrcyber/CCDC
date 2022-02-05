#!/bin/sh

# Check for root
if [ $(whoami) != "root" ]; then
	echo "Script must be run as root"
	exit 1
fi

# Formatted output
becho() {
	echo "$(tput bold)$1...$(tput sgr0)"
}

# Create backups directory 
mkdir -p /var/backups

becho "Backing up pam"
cp -r /etc/pam* /var/backups
cp -r /lib/security* /var/backup

becho "Backing up configuration files from /etc"
cp -r /etc /var/backup

if [ -d "/var/www" ]; then
	becho "Backing up web files"
	cp -r /var/www /var/backup
fi

becho "Making backups immutable"
chattr +i -RV /var/backups/*