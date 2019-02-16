#!/usr/bin/env bash

# Check if user is root
if [[ $EUID -ne 0 ]]; then
	printf "\nScript must be run as root\n"
	exit 1
fi

# /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// #
# /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// #
# /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// #

# This script is supposed to automate a lot of the beginning steps on the linux side

# /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// #
# /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// #
# /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// #

# /// TODO:
# /// [[ doneForDebian/Ubuntu ]] install OSSEC (client & server),
# /// ELK/Splunk
# /// (delay) Replace Sources.list with defaults for distros to automate the auditing process
# /// Turn off all SystemD/init services that are not part of system (WATCH OUT FOR WEBSERVERS & SUCH!)
# /// [[ DONE? ]] default iptables rules (block ssh, ipv6, icmp, ddos, etc)
# /// [[ DONE? ]] Edit sshd configs and such
# /// [[ seperate? ]] Ansible playbook
# /// FTP/DNS security
# /// [[ doneForCentOS/RHEL/Fedora) ]] modsecurity
# /// replace default rc files with safe ones, ie bashrc with a default with secure aliases and such
# /// check var spool for cron as well as etc
# /// change wordpress passwords
# /// change db passwords
# /// nesses
# /// fail2ban
# /// exim4

# /// watch out for
# /// automated scans, stop user agents (hi im firefox)
# /// use a local scanner () to find and repair our stuff before hand
# /// check permissions on web to stop
# /// look up BloodHound (windows),

# /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// #
# /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// #
# /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// #

# /// DISTROS TO DO
# ///
# /// FREEBSD!!!!!
# ///
# /// Mint/Ubuntu/Debian, CentOS/RHEL/Fedora,
# /// Alpine, Arch, Gentoo, elementaryOS,
# /// Manjaro, ?KDE Neon?, Void linux, OpenSUSE, ?BSD?
# /// MAYBE?: BSD jails, Container Hells, Dockers

# /// know basic services: POSTFIX, bind, ftp?, dns?, sambashare, apache

# /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// #
# /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// #
# /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// #

#loops so the user can do multiple options after each others
while [ true ]
do

printf '\n\n\n\nEnter number of choice:\n'
printf 'Option 1 : change passwords.\n'
printf 'Option 2 : disable ipv6. (Systems with sysctl)\n'
printf 'Option 3 : chattr +i /etc/group,shadow,sudoers,sysctl*,cron*,anacrontab [[ TODO ]] /etc/<sources> (Did you audit the files?)\n'
printf 'Option 4 : chattr -i (undo option 3 & others that chattr +i)\n'
printf 'Option 5 : install OSSEC client/server [[ TODO ]] ELK / Splunk \n'
printf 'Option 6 : Update and Upgrade system\n'
printf 'Option 7 : default iptables & chattr +i to backup\n'
printf 'Option 8 : Secures /etc/ssh/ssh_config and chattr +i\n'
printf 'Option 9 : Change permissions on /root /home/* to only be for root & the respective owner of home*\n'
printf 'Option 10 : (ONLY CENTOS) install mod_security\n'
printf 'Option 11 : setup Ansible client/server\n'
printf 'Option 12 : Secure PostFix mail\n'
printf 'Option 13 : nmap -A -T4 192.168.1.0/24 >> nmapScan.txt\n'

printf '[[ TODO ]] Option 14 : default rc files & chattr +i for nano/vi/vim/bash/zsh/fsh/etc ...\n'
printf '[[ TODO ]] Option 15 : audit SystemD services\n'
printf '[[ TODO ]] Option 16 : domain join linux\n'
printf '[[ TODO ]] Option 17 : Remove GCC, NC\n'
printf ' (delay) [[ TODO ]] Option 18 : audit sources/mirrors\n'
printf '[[ TODO ]] Option 19 : install and setup fail2ban\n'
printf '[[ TODO ]] Option 20 : secure exim4\n'
printf '[[ TODO ]] Option 21 : secure RedMail\n'
printf '[[ TODO ]] Option 22 : remove FTP/Telnet/Rlogin/Rsh services\n'

read -r option

if [[ -z "$option" ]]; then
	printf '\nInvalid option\n'
fi



#change passwords
if [[ "$option" = "1" ]]; then
	printf '\nEnter the new password template: '
	read -r passTemp
	printf '\nConfirm: '
	read -r passConfirm

	if [[ -z "$passTemp" ]] || [[ "$passTemp" != "$passConfirm" ]]; then
		printf '\nInvalid new password\n'
		exit 2
	fi

# host=$(hostname)
	for user in $(awk -F: '$7 ~ /(\/sh|\/bash)/ { print $1 }' /etc/passwd); do
		if [[ $(id -u $user) -eq 0 ]]; then # Don't change password for root
			continue
		fi
		echo ""
		echo "\nChanging password for $user"
		newPass="$passTemp$user"
		echo -e "$newPass\\n$newPass" | passwd "$user"
	done

	printf '\nPASSWORDS CHANGED!\n'
fi




#disables ipv6
if [[ "$option" = "2" ]]; then
	if [ ! -f /etc/sysctl.conf ]; then
		echo "\nSorry! No /etc/sysctl.conf exists!"
	else
		echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf
		echo 'net.ipv6.conf.default.disable_ipv6 = 1' >> /etc/sysctl.conf
		#cat /etc/sysctl.conf
		printf '\nRunning sysctl -p /etc/sysctl.conf\n'
		sysctl -p /etc/sysctl.conf
		printf '\nipv6 DISABLED!\n'
	fi
fi



#chattr +i shadow,sudoers,group
if [[ "$option" = "3" ]]; then
	printf '\nDid you audit the files first? (Y/N)\n'
	read -r option

	if [[ -z "$option" ]]; then
		printf '\nInvalid option\n'
	fi

	if [[ "$option" = "Y"  ]] || [[ "$option" = "y" ]]; then
		printf '\nGood\n'
		printf '\nLocking /etc/shadow /etc/gshadow'
		chattr +i /etc/shadow && chattr +i /etc/gshadow
		printf '\nLocking /etc/group'
		chattr +i /etc/group
		printf '\nLocking /etc/sudoers & sudoers.d'
		chattr +i /etc/sudoers && chattr -R +i /etc/sudoers.d
		printf '\nLocking /etc/sysctl.conf /etc/sysctl.d'
		chattr +i /etc/sysctl.conf && chattr -R +i /etc/sysctl.d
		printf '\nLocking /etc/cron* /etc/anacrontab'
		chattr +i /etc/anacrontab && chattr -R +i /etc/cron.d && chattr -R +i /etc/cron.daily && chattr -R +i /etc/cron.hourly && chattr -R +i /etc/cron.monthly && chattr +i /etc/crontab && chattr -R +i /etc/cron.weekly

		#check distrib to +i to sources
		#TODO: SystemD services

		printf '\n\nLook! They are changed!\n'
		lsattr /etc/group /etc/shadow /etc/gshadow /etc/sudoers /etc/sudoers.d /etc/sysctl.conf /etc/sysctl.d /etc/anacrontab /etc/cron*
		printf '\nDone\n'
	fi

	if [[ "$option" = "N"  ]] || [[ "$option" = "n" ]]; then
		printf '\nThen what are you waiting for!!\n'
	fi

fi



#chattr -i shadow,sudoers,group
if [[ "$option" = "4" ]]; then
	printf '\nUnlocking /etc/shadow /etc/gshadow'
	chattr -i /etc/shadow && chattr -i /etc/gshadow
	printf '\nUnlocking /etc/group'
	chattr -i /etc/group
	printf '\nUnlocking /etc/sudoers & sudoers.d'
	chattr -i /etc/sudoers && chattr -R -i /etc/sudoers.d
	printf '\nUnlocking /etc/sysctl.conf /etc/sysctl.d'
	chattr -i /etc/sysctl.conf && chattr -R -i /etc/sysctl.d
	printf '\nUnlocking /etc/cron* /etc/anacrontab'
	chattr -i /etc/anacrontab && chattr -R -i /etc/cron.d && chattr -R -i /etc/cron.daily && chattr -R -i /etc/cron.hourly && chattr -R -i /etc/cron.monthly && chattr -i /etc/crontab && chattr -R -i /etc/cron.weekly
	printf '\nUnlocking /etc/ssh/*\n'
	chattr -i /etc/ssh/*

	printf '\n\nLook! They are changed!\n'
	lsattr /etc/group /etc/shadow /etc/gshadow /etc/sudoers /etc/sudoers.d /etc/sysctl.conf /etc/sysctl.d /etc/anacrontab /etc/cron* /etc/ssh/*
	printf '\nDone\n'
fi



#install OSSEC / ELK
if [[ "$option" = "5" ]]; then
	printf '\nPrereq: download & install build-essentials, inotify-tools\n'
	ID_LIKE="$(cat /etc/*release | grep "ID_LIKE")"

	printf '\nDo you want [E]LK or [S]plunk? or [N]either?\n'
	read -r optionEorS

	#checks for distros
	if [[ ${ID_LIKE} = "ID_LIKE=debian" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"debian\"" ]]; then
		apt-get install build-essential inotify-tools wget
		wget -U ossec https://bintray.com/artifact/download/ossec/ossec-hids/ossec-hids-2.8.3.tar.gz
		tar -xvzf ossec-hids-2.8.3.tar.gz
		cd ossec-hids-2.8.3
		./install.sh
		printf '\nIs OSSEC running?\n'
		/var/ossec/bin/ossec-control status
		printf '\nJust in case, we start anyway\n'
		/var/ossec/bin/ossec-control restart
		printf '\nNow, enter to server key\n'
		/var/ossec/bin/manage_agents
		printf '\nTime to restart OSSEC\n'
		/var/ossec/bin/ossec-control restart
		echo "To set up mail, get alerts and change frequency of scans, go to /var/ossec/etc/ossec.conf"
		echo "To make your own rules, and severiry of broken rules, go to /var/ossec/rules/local_rules.xml"

		#setup Elk
		if [[ "$optionEorS" = "E" ]] || [[ "$optionEorS" = "e" ]] || [[ "$optionEorS" = "ELK" ]] || [[ "$optionEorS" = "elk" ]] || [[ "$optionEorS" = "Elk" ]]; then
			printf '\nPrereq: java8\n'
			add-apt-repository -y ppa:webupd8team/java
			apt-get update
			apt-get -y install oracle-java8-installer wget
			printf '\nTime for Elasticsearch\n'
			wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
			chattr -i /etc/apt/*
			echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list
			apt-get update
			apt-get -y install elasticsearch
			sed -i 's/# network.host: 192.168.0.1/network.host: localhost/' /etc/elasticsearch/elasticsearch.yml
			service elasticsearch restart
			update-rc.d elasticsearch defaults 95 10

			printf '\nTime for Kibana!\n'
			echo "deb http://packages.elastic.co/kibana/4.5/debian stable main" | sudo tee -a /etc/apt/sources.list.d/kibana-4.5.x.list
			apt-get update
			apt-get -y install kibana
			vi /opt/kibana/config/kibana.yml #See the linux google doc for what to add
			update-rc.d kibana defaults 96 9
			service kibana start

			printf '\nTime for Nginx!\n'
			apt-get install nginx apache2-utils
			htpasswd -c /etc/nginx/htpasswd.users jeff #jeff is the kibanaadmin name
			rm -rf /etc/nginx/sites-available/default
			touch /etc/nginx/sites-available/default
			printf '\nWhat is the server_name? (example.com)\n'
			read -r serverName
			echo "
			server {
		  		listen 80;

				server_name $serverName;

		    		auth_basic "Restricted Access";
				auth_basic_user_file /etc/nginx/htpasswd.users;

		       		location / {
					proxy_pass http://localhost:5601;
					proxy_http_version 1.1;
					proxy_set_header Upgrade $http_upgrade;
					proxy_set_header Connection 'upgrade';
					proxy_set_header Host $host;
					proxy_cache_bypass $http_upgrade;
				}
		    	}
			" >> /etc/nginx/sites-available/default
			service nginx restart

			printf '\nTime for Logstash\n'
			echo 'deb http://packages.elastic.co/logstash/2.2/debian stable main' | sudo tee /etc/apt/sources.list.d/logstash-2.2.x.list
			apt-get update
			apt-get install logstash
			#Generate SSL Certificates and use IP address instead of DNS
			mkdir -p /etc/pki/tls/certs
			mkdir /etc/pki/tls/private
			vi /etc/ssl/openssl.cnf #See the linux google doc for what to add
			cd /etc/pki/tls
			sudo openssl req -config /etc/ssl/openssl.cnf -x509 -days 3650 -batch -nodes -newkey rsa:2048 -keyout private/logstash-forwarder.key -out certs/logstash-forwarder.crt
			vi /etc/logstash/conf.d/02-beats-input.conf #See the linux google doc for what to add
			vi /etc/logstash/conf.d/10-syslog-filter.conf #See the linux google doc for what to add
			vi /etc/logstash/conf.d/30-elasticsearch-output.conf #See the linux google doc for what to add
			service logstash configtest
			service logstash restart
			update-rc.d logstash defaults 96 9

			printf '\nLoad Kibana Dashboards\n'
			cd ~
			curl -L -O https://download.elastic.co/beats/dashboards/beats-dashboards-1.1.0.zip
			apt-get -y install unzip
			unzip beats-dashboards-*.zip
			cd beats-dashboards-*
			./load.sh

			printf '\nLoad Filebeat Index Template in Elasticsearch\n'
			cd ~
			curl -O https://gist.githubusercontent.com/thisismitch/3429023e8438cc25b86c/raw/d8c479e2a1adcea8b1fe86570e42abab0f10f364/filebeat-index-template.json
			curl -XPUT 'http://localhost:9200/_template/filebeat?pretty' -d@filebeat-index-template.json

			printf '\nSet Up Filebeat (Add Client Servers) Coppies SSL certs to clients\n'
			printf 'Enter user name: '
			read -r user
			printf '\nEnter the IP addess'
			read -r clientServerPrivateAddress
			scp /etc/pki/tls/certs/logstash-forwarder.crt $user@$clientServerPrivateAddress :/tmp

		fi

		#setup Splunk
		if [[ "$optionEorS" = "S" ]] || [[ "$optionEorS" = "s" ]] || [[ "$optionEorS" = "Splunk" ]] || [[ "$optionEorS" = "splunk" ]]; then
			printf '\n[[TODO]]\n'
		fi

		#user wants neither
		if [[ "$optionEorS" = "N" ]] || [[ "$optionEorS" = "n" ]] || [[ "$optionEorS" = "No" ]] || [[ "$optionEorS" = "no" ]] || [[ "$optionEorS" = "Neither" ]] || [[ "$optionEorS" = "neither" ]]; then
			printf '\n[[TODO]]\n'
		fi

	fi

	if [[ ${ID_LIKE} = "ID_LIKE=arch" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"arch\"" ]]; then
		printf '\nDone, but needs testing, WARNING!\n'
		# commands from the arch wiki, I think I figured it out
		# but an arch user needs to approve the following
		# or we can test it

		pacman -S build-essential inotfify-tools wget
		wget -U ossec https://bintray.com/artifact/download/ossec/ossec-hids/ossec-hids-2.8.3.tar.gz
		tar -xvzf ossec-hids-2.8.3.tar.gz
		cd ossec-hids-2.8.3
		./install.sh
		printf '\nIs OSSEC running?\n'
		/var/ossec/bin/ossec-control status
		printf '\nJust in case, we start anyway\n'
		/var/ossec/bin/ossec-control restart
		printf '\nNow, enter to server key\n'
		/var/ossec/bin/manage_agents
		printf '\nTime to restart OSSEC\n'
		/var/ossec/bin/ossec-control restart
		echo "To set up mail, get alerts and change frequency of scans, go to /var/ossec/etc/ossec.conf"
		echo "To make your own rules, and severiry of broken rules, go to /var/ossec/rules/local_rules.xml"


		#setup Elk
		if [[ "$optionEorS" = "E" ]] || [[ "$optionEorS" = "e" ]] || [[ "$optionEorS" = "ELK" ]] || [[ "$optionEorS" = "elk" ]] || [[ "$optionEorS" = "Elk" ]]; then
			printf '\n[[TODO]]\n'
		fi

		#setup Splunk
		if [[ "$optionEorS" = "S" ]] || [[ "$optionEorS" = "s" ]] || [[ "$optionEorS" = "Splunk" ]] || [[ "$optionEorS" = "splunk" ]]; then
			printf '\n[[TODO]]\n'
		fi

		#user wants neither
		if [[ "$optionEorS" = "N" ]] || [[ "$optionEorS" = "n" ]] || [[ "$optionEorS" = "No" ]] || [[ "$optionEorS" = "no" ]] || [[ "$optionEorS" = "Neither" ]] || [[ "$optionEorS" = "neither" ]]; then
			printf '\n[[TODO]]\n'
		fi

	fi

	if [[ ${ID_LIKE} = "ID_LIKE=rhel fedora" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"rhel fedora\"" ]]; then
		printf '\nDone, but needs testing, WARNING!\n'
		# commands from stackExchange, I think I figured it out
		# but we need to test it

		yum groupinstall 'Development Tools'
		yum install inotify-tools
		yum install wget
		wget -U ossec https://bintray.com/artifact/download/ossec/ossec-hids/ossec-hids-2.8.3.tar.gz
		tar -xvzf ossec-hids-2.8.3.tar.gz
		cd ossec-hids-2.8.3
		./install.sh
		printf '\nIs OSSEC running?\n'
		/var/ossec/bin/ossec-control status
		printf '\nJust in case, we start anyway\n'
		/var/ossec/bin/ossec-control restart
		printf '\nNow, enter to server key\n'
		/var/ossec/bin/manage_agents
		printf '\nTime to restart OSSEC\n'
		/var/ossec/bin/ossec-control restart
		echo "To set up mail, get alerts and change frequency of scans, go to /var/ossec/etc/ossec.conf"
		echo "To make your own rules, and severiry of broken rules, go to /var/ossec/rules/local_rules.xml"

		#setup Elk
		if [[ "$optionEorS" = "E" ]] || [[ "$optionEorS" = "e" ]] || [[ "$optionEorS" = "ELK" ]] || [[ "$optionEorS" = "elk" ]] || [[ "$optionEorS" = "Elk" ]]; then
			printf '\n[[TODO]]\n'
		fi

		#setup Splunk
		if [[ "$optionEorS" = "S" ]] || [[ "$optionEorS" = "s" ]] || [[ "$optionEorS" = "Splunk" ]] || [[ "$optionEorS" = "splunk" ]]; then
			printf '\n[[TODO]]\n'
		fi

		#user wants neither
		if [[ "$optionEorS" = "N" ]] || [[ "$optionEorS" = "n" ]] || [[ "$optionEorS" = "No" ]] || [[ "$optionEorS" = "no" ]] || [[ "$optionEorS" = "Neither" ]] || [[ "$optionEorS" = "neither" ]]; then
			printf '\n[[TODO]]\n'
		fi

	fi

fi



#Update and Upgrade system
if [[ "$option" = "6" ]]; then
	ID_LIKE="$(cat /etc/*release | grep "ID_LIKE")"
	printf '\nDid you audit the source files first? (Y/N)\n'
	read -r option

	if [[ -z "$option" ]]; then
		printf '\nInvalid option\n'
	fi

	if [[ "$option" = "Y"  ]] || [[ "$option" = "y" ]]; then
		if [[ ${ID_LIKE} = "ID_LIKE=rhel fedora" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"rhel fedora\"" ]]; then
			yum update && yum upgrade
		fi

		if [[ ${ID_LIKE} = "ID_LIKE=arch" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"arch\"" ]]; then
			pacman -Syu
		fi

		if [[ ${ID_LIKE} = "ID_LIKE=debian" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"debian\"" ]]; then
			apt-get update && apt-get upgrade
		fi

	fi

	if [[ "$option" = "N"  ]] || [[ "$option" = "n" ]]; then
		printf '\nThen what are you waiting for!!\n'
	fi
fi



#Does some basic Network Binder setup stuff
if [[ "$option" = "7" ]]; then
	printf '\nSaving iptables to ~/iptablesBackupBefore.txt . . .\n'
	touch ~/iptablesBackupBefore.txt
	iptables-save
	iptables -L >> ~/iptablesBackupBefore.txt
	printf '\nFlushing rules . . .\n'
	iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -t raw -F
	printf '\nWiping out all non-default chains . . .\n'
	iptables -X && iptables -t nat -X && iptables -t mangle -X && iptables -r raw -X
	printf '\nAllow all loopback traffic\n'
	iptables -A INPUT -i lo -j ACCEPT
	iptables -A OUTPUT -o lo -j ACCEPT
	printf '\nAllows IN connections to any public services, default ports are 20,80,443\nmake sure to run the commands with the services the computer needs\n'
	iptables -A INPUT -p tcp -m multiport --dports 22,80,443 -j ACCEPT
	iptables -A INPUT -p tch -m state --state RELATED,ESTABLISHED -j ACCEPT
	printf '\nLog outgoing connections\n'
	iptables -A OUTPUT -m state --state new -j LOG --log-uid
	printf '\nBlock ICMP\n'
	iptables -I INPUT -p icmp --icmp-type 0 -j DROP
	iptables -I OUTPUT -p icmp --icmp-type 8 -j DROP
	printf '\nDone\nSaving new iptable rules\n'
	touch ~/iptablesBackupAfter.txt
	iptables-save
	iptables -L >> ~/iptablesBackupAfter.txt
	chattr +i ~/iptablesBackupBefore.txt
	chattr +i ~/iptablesBackupAfter.txt
fi



#ssh configs
if [[ "$option" = "8" ]]; then
	echo "
Protocol 2
AllowUsers root admin webmaster
AllowGroup sshusers
PasswordAuthentication no
HostbasedAuthentication no
RSAAuthentication yes
PubkeyAuthentication yes
PermitEmptyPasswords no
PermitRootLogin no
ServerKeyBits 2048
IgnoreRhosts yes
RhostsAuthentication no
RhostsRSAAuthentication no" >> /etc/ssh/ssh_config

	chattr +i /etc/ssh/ssh_config
	lsattr /etc/ssh/*
	printf '\nDone\n'
fi



#change permissions to only be root
if [[ "$option" = "9" ]]; then
	printf '\nChanging Permissions on /root & /home/* . . .\n'
	chmod -Rv go-rwx /root
	chmod -Rv go-w /home/*
fi


#install mod_security
if [[ "$option" = "10" ]]; then
	ID_LIKE="$(cat /etc/*release | grep "ID_LIKE")"

	if [[ ${ID_LIKE} = "ID_LIKE=rhel fedora" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"rhel fedora\"" ]]; then
		yum install epel-release
		yum install mod_security
		yum install mod_security_crs mod_security_crs-extras
		yum install git
		service httpd restart
		cd /etc/httpd
		yum install git
		git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git
		cd owasp-modsecurity-crs
		git checkout v2.2/master
		cp -av base_rules/* slr_rules/* /etc/httpd/modsecurity.d/activated_rules
		service httpd restart
	fi

	if [[ ${ID_LIKE} != "ID_LIKE=rhel fedora" ]] || [[ ${ID_LIKE} != "ID_LIKE=\"rhel fedora\"" ]]; then
		printf '\nSorry, cant help you right now!\n'
	fi

fi




#setup Ansible client/server
if [[ "$option" = "11" ]]; then
	ID_LIKE="$(cat /etc/*release | grep "ID_LIKE")"
	printf '\n[C]lient or [S]erver?\n'
	read -r optionCorS

	if [[ ${ID_LIKE} = "ID_LIKE=debian" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"debian\"" ]]; then
		if [[ "$optionCorS" = "C" ]] || [[ "$optionCorS" = "c" ]] || [[ "$optionCorS" = "Client" ]] || [[ "$optionCorS" = "client" ]] || [[ "$optionCorS" = "CLIENT" ]]; then
			printf '\nInstalling Ansible\n'
			chattr -i /etc/apt/*
			apt-get update
			apt-get install software-properties-common
	 		apt-add-repository ppa:ansible/ansible
			apt-get update
			apt-get install ansible
			printf '\nAll set! Be sure to edit the /etc/ansible/hosts file and to place the ssh key from the server in ~/.ssh/authorized_keys\n'
			chattr +i /etc/apt/*
		fi

		if [[ "$optionCorS" = "S" ]] || [[ "$optionCorS" = "s" ]] || [[ "$optionCorS" = "Server" ]] || [[ "$optionCorS" = "server" ]] || [[ "$optionCorS" = "SERVER" ]]; then
			printf '\nInstalling Ansible\n'
			chattr -i /etc/apt/*
			apt-get update
			apt-get install software-properties-common
			apt-add-repository ppa:ansible/ansible
			apt-get update
			apt-get install ansible
			ssh-keygen
			printf '\nAll set! Be sure to edit the /etc/ansible/hosts file and to place the PUBLIC ssh key from the server in ~/.ssh/authorized_keys on the clients\n'
			chattr +i /etc/apt/*
		fi
	fi

	if [[ ${ID_LIKE} = "ID_LIKE=rhel fedora" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"rhel fedora\"" ]]; then
		if [[ "$optionCorS" = "C" ]] || [[ "$optionCorS" = "c" ]] || [[ "$optionCorS" = "Client" ]] || [[ "$optionCorS" = "client" ]] || [[ "$optionCorS" = "CLIENT" ]]; then
			printf '\nInstalling Ansible\n'
			yum install epel-release
			yum update
			yum install ansible
			printf '\nAll set! Be sure to edit the /etc/ansible/hosts file and to place the ssh key from the server in ~/.ssh/authorized_keys\n'
		fi

		if [[ "$optionCorS" = "S" ]] || [[ "$optionCorS" = "s" ]] || [[ "$optionCorS" = "Server" ]] || [[ "$optionCorS" = "server" ]] || [[ "$optionCorS" = "SERVER" ]]; then
			printf '\nInstalling Ansible\n'
			yum install epel-release
			yum update
			yum install ansible
			ssh-keygen
			printf '\nAll set! Be sure to edit the /etc/ansible/hosts file and to place the PUBLIC ssh key from the server in ~/.ssh/authorized_keys on the clients\n'
		fi
	fi

	if [[ ${ID_LIKE} = "ID_LIKE=arch" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"arch\"" ]]; then
		if [[ "$optionCorS" = "C" ]] || [[ "$optionCorS" = "c" ]] || [[ "$optionCorS" = "Client" ]] || [[ "$optionCorS" = "client" ]] || [[ "$optionCorS" = "CLIENT" ]]; then
			printf '\nInstalling Ansible\n'
			pacman -S python
			printf '\nAll set! Be sure to edit the /etc/ansible/hosts file and to place the ssh key from the server in ~/.ssh/authorized_keys\n'
		fi

		if [[ "$optionCorS" = "S" ]] || [[ "$optionCorS" = "s" ]] || [[ "$optionCorS" = "Server" ]] || [[ "$optionCorS" = "server" ]] || [[ "$optionCorS" = "SERVER" ]]; then
			printf '\nInstalling Ansible\n'
			pacman -S python
			pacman -S ansible
			ssh-keygen
			printf '\nAll set! Be sure to edit the /etc/ansible/hosts file and to place the PUBLIC ssh key from the server in ~/.ssh/authorized_keys on the clients\n'
		fi
	fi

fi




#Secures PostFix
if [[ "$option" = "12" ]]; then
	printf '\nMake sure Postfix is running as NON-ROOT!!\n'
	ps aux | grep postfix | grep -v '^root'
	printf '\nIf it is NOT root say \"Y\" otherwise say \"N\"\n'
	read -r isPostfixRoot

	if [[ "$isPostfixRoot" = "Y" ]] || [[ "$isPostfixRoot" = "y" ]]; then
		printf '\nGreat!\nTime to change permissions'
		chmod 755 /etc/postfix
		chmod 644 /etc/postfix/*.cf
		chmod 755 /etc/postfix/postfix-script*
		chmod 755 /var/spool/postfix
		chown root:root /var/log/mail*
		chmod 600 /var/log/mail*
		#printf '\nWhat is the mail.server.example.com?\n'
		#read -r myServer
		#printf '\nWhat is the IP adress on the NIC postfix should listen on?\n'
		#read -r myNICIP
		#sed -i 's/inet_interfaces = all/inet_interfaces = $myNICIP/' /etc/postfix/main.cf
		vi /etc/postfix/main.cf # check linux google doc on what to add
		service postfix restart
	fi

	if [[ "$isPostfixRoot" = "N" ]] || [[ "$isPostfixRoot" = "n" ]]; then
		printf '\nSince it is not root, kill it and start as root\n'
	fi

fi






if [[ "$option" = "13" ]]; then
	ID_LIKE="$(cat /etc/*release | grep "ID_LIKE")"
	printf '\nInstalling nmap\n'

	if [[ ${ID_LIKE} = "ID_LIKE=debian" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"debian\"" ]]; then
		printf '\nDebian? cool!'
		apt-get update && apt-get install nmap -y
		nmap -A -T4 192.168.1.0/24 >> nmapScan.txt &
	fi

	if [[ ${ID_LIKE} = "ID_LIKE=rhel fedora" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"rhel fedora\"" ]]; then
		yum update && yum install nmap
		nmap -A -T4 192.168.1.0/24 >> nmapScan.txt &
	fi

	if [[ ${ID_LIKE} = "ID_LIKE=arch" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"arch\"" ]]; then
		pacman -S nmap
		nmap -A -T4 192.168.1.0/24 >> nmapScan.txt &
	fi

	printf '\nThe nmap scan is now running in the background! Check for the txt in about 2 min!'
fi





#default rc files
if [[ "$option" = "14" ]]; then
	printf '\nTODO\n'
fi




#audit SystemD services
if [[ "$option" = "15" ]]; then
	printf '\nTODO\n'
fi





#domain join linux to windows AD and stuff
if [[ "$option" = "16" ]]; then
	printf '\nTODO\n'
fi




#Removes GCC, NC
if [[ "$option" = "17" ]]; then
	WHICH_GCC="$(which gcc")"
	ID_LIKE="$(cat /etc/*release | grep "ID_LIKE")"

	if [[ ${WHICH_GCC} = "" ]]; then
		printf '\nNo GCC found!\n'
	fi

	if [[ ${ID_LIKE} = "ID_LIKE=rhel fedora" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"rhel fedora\"" ]]; then
		yum remove gcc*
	fi

	if [[ ${ID_LIKE} = "ID_LIKE=arch" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"arch\"" ]]; then
		pacman -Rs gcc*
	fi

	if [[ ${ID_LIKE} = "ID_LIKE=debian" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"debian\"" ]]; then
		apt-get purge gcc*
	fi

	printf '\nDone!\n'
fi





#audit sources/mirrors
if [[ "$option" = "18" ]]; then
	ID_LIKE="$(cat /etc/*release | grep "ID_LIKE")"

	if [[ ${ID_LIKE} = "ID_LIKE=rhel fedora" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"rhel fedora\"" ]]; then
		printf '\nTODO\n'
	fi

	if [[ ${ID_LIKE} = "ID_LIKE=arch" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"arch\"" ]]; then
		printf '\nTODO\n'
	fi

	if [[ ${ID_LIKE} = "ID_LIKE=debian" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"debian\"" ]]; then
		printf '\nTODO\n'
	fi
	printf '\nTODO\n'
fi





#installs and sets up fail2ban
if [[ "$option" = "19" ]]; then
	ID_LIKE="$(cat /etc/*release | grep "ID_LIKE")"

	if [[ ${ID_LIKE} = "ID_LIKE=rhel fedora" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"rhel fedora\"" ]]; then
		yum update
		yum install fail2ban
	fi

	if [[ ${ID_LIKE} = "ID_LIKE=arch" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"arch\"" ]]; then
		pacman -Syu
		pacman -S fail2ban
	fi

	if [[ ${ID_LIKE} = "ID_LIKE=debian" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"debian\"" ]]; then
		apt-get update
		apt-get install fail2ban
		awk '{ printf "# "; print; }' /etc/fail2ban/jail.conf | sudo tee /etc/fail2ban/jail.local

	fi
	printf '\nTODO\n'
fi




#remove FTP/Telnet/Rlogin/Rsh services
if [[ "$option" = "22" ]]; then
	ID_LIKE="$(cat /etc/*release | grep "ID_LIKE")"

	if [[ ${ID_LIKE} = "ID_LIKE=rhel fedora" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"rhel fedora\"" ]]; then
		yum erase xinetd ypserv tftp-server telnet-server rsh-server
	fi

	if [[ ${ID_LIKE} = "ID_LIKE=arch" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"arch\"" ]]; then
		printf '\nTODO\n'
	fi

	if [[ ${ID_LIKE} = "ID_LIKE=debian" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"debian\"" ]]; then
		sudo apt-get --purge remove xinetd nis yp-tools tftpd atftpd tftpd-hpa telnetd rsh-server rsh-redone-server
	fi
	printf '\nTODO\n'
fi


#ends while loop
done
