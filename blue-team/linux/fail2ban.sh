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

declare -A osInfo;
osInfo[/etc/redhat-release]="yum install"
osInfo[/etc/debian_version]="apt install"
osInfo[/etc/alpine-release]="apk add"
osInfo[/etc/arch-release]="pacman -S"
osInfo[/etc/centos-release]="rpm -i"

for f in ${!osInfo[@]}
do
    if [[ -f $f ]]; then
		if [[ "$f" == "/etc/centos-release" ]]; then
			becho "Adding EPEL repository"
			yum install -y epel-release
		fi
		
		becho "Installing fail2ban with ${osInfo[$f]} fail2ban"
		"$(${osInfo[$f]} fail2ban)"
		
		becho "Creating fail2ban config"
		cat > /etc/fail2ban/jail.local <<- EOM
			[sshd]
			enabled = true
			bantime = 5m
			maxretry = 3
		EOM

		becho "Enabling fail2ban service"
		systemctl enable --now fail2ban
    fi
done

