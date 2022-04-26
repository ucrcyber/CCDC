#!/bin/bash

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
osInfo[/etc/redhat-release]="yum install -y"
osInfo[/etc/debian_version]="apt install -y"
osInfo[/etc/alpine-release]="apk add"
osInfo[/etc/arch-release]="pacman -S"

for f in ${!osInfo[@]}
do
    if [[ -f $f ]]; then
        if [[ -f "/etc/centos-release" ]]; then
            becho "Adding EPEL repository"
            yum install -y epel-release
        fi
        
        becho "Installing fail2ban with ${osInfo[$f]} fail2ban"
        echo "$(${osInfo[$f]} fail2ban)"
        
        becho "Creating fail2ban config"
		cat > /etc/fail2ban/jail.local <<- EOM
			[sshd]
			enabled = true
			bantime = 5m
			maxretry = 3
		EOM
        
        becho "Enabling fail2ban service"
        if [[ "$f" == "/etc/alpine-release" ]]; then
            rc-update add fail2ban
            rc-service fail2ban start
        else
            systemctl enable --now fail2ban
        fi
    fi
done
