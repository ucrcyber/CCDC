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

if [ -d "/var/lib/mysql"]
then
	becho "Backing up mysql"
	# Info for restoring: https://serverfault.com/questions/659048/can-i-copy-the-entire-var-lib-mysql-folder-to-a-different-server-mysql-vs-mar
	cp -r /var/lib/mysql /var/backup

	# Alternative
	# mysqldump --all-databases --single-transaction --quick --lock-tables=false > /var/backups/mysql_full-backup-$(date +%F).sql -u root -p
fi

if [ -d "/var/www" ]; then
	becho "Backing up web files"
	cp -r /var/www /var/backup
fi

becho "Making backups immutable"
chattr +i -RV /var/backups/*