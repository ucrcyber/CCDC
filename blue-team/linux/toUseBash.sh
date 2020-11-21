#!/bin/bash

# STILL IN PROCESS OF REWRITING THIS

if [ `whoami` != "root" ]; then
	echo "\nScript must be run as root\n"
	exit 1
fi

changePasswords() {
	echo 'Enter the new password template:'
	read -r passTemp
	echo 'Confirm:'
	read -r passConfirm

	if [ -z "$passTemp" ] || [ "$passTemp" != "$passConfirm" ]; then
		echo 'Invalid new password'
		exit 2
	fi

	# thanks Nate!!
	while read line; do
		a="$(cut -d':' -f3 <<<$line)"
		if [ $a -ge 1000  ] && [ $a -lt 65534 ]; then 
			user="$(cut -d':' -f1 <<<$line)"
			echo "Changing password for $user"
			newPass="$passTemp$user"
			echo -e "$newPass\\n$newPass" | passwd "$user"
        fi
    done < /etc/passwd

	for user in $(awk -F: '$7 ~ /(\/sh|\/bash)/ { print $1 }' /etc/passwd); do
		if [ $(id -u $user) -eq 0 ]; then # Don't change password for root
			continue
		fi
		echo "Changing password for $user"
		newPass="$passTemp$user"
		echo -e "$newPass\\n$newPass" | passwd "$user"
	done
}

while [ true ]; do
	prompt='\nEnter number of choice:\nOption 1 : change passwords.' #\nOption 2 : disable ipv6\nOption 3 : chattr +i /etc/group,shadow,sudoers,sysctl*,cron*,anacrontab [[ TODO ]] /etc/<sources> (Did you audit the files?)\nOption 4 : chattr -i (undo option 3 & others that chattr +i)\nOption 5 : install OSSEC client/server [[ TODO ]] ELK / Splunk \nOption 6 : Update and Upgrade system\nOption 7 : default iptables & chattr +i to backup\nOption 8 : Secures /etc/ssh/ssh_config and chattr +i\nOption 9 : Change permissions on /root /home/* to only be for root & the respective owner of home*\nOption 10 : install mod_security\nOption 11 : Secures PostFix\nOption 12 : nmap -A -T4 -sC -sV -v <IP>/24 >> nmapScan.txt &\n'
	echo -e $prompt
	read -r option

	case $option in
		"1")
			echo '\n1\n'
			changePasswords
			;;
	esac

done
