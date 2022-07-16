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
cp -r /lib/security* /var/backups

becho "Backing up configuration files from /etc"
cp -r /etc /var/backups

if [ -d "/var/www" ]; then
    becho "Backing up web files"
    cp -r /var/www /var/backups
fi

if [ -d "/var/lib/mysql" ]; then
    becho "Backing up MySQL"
    mysqldump -u root -p --all-databases > /var/backups/mysql.sql
fi

becho "Making backups immutable"
chattr +i -R /var/backups/*