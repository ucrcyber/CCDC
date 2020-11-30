#!/bin/bash

if [ `whoami` != "root" ]; then
        echo "Script must be run as root"
        exit 1
fi

echo Ll9fICAgICAgICBfXyAgICAgICAgX19fLiAgIC5fXyAgICAgICAgICAgICAgICAgCnxfX3xfX19fX18vICB8X19fX>

sudo timedatectl set-timezone America/Los_Angeles
sudo systemctl restart rsyslog

sudo iptables -F
sudo iptables -A INPUT -p tcp --dport 23 -j DROP
sudo iptables -X LOGGING
sudo iptables -N LOGGING
sudo iptables -A INPUT -j LOGGING
sudo iptables -A LOGGING -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j LOG --log-prefi>
sudo iptables -I OUTPUT -p tcp -m tcp --sport 22 -m state --state NEW,ESTABLISHED -j LOG --log>
sudo iptables -A LOGGING -j ACCEPT

echo Done!

exit
