#!/bin/sh

if [ $(whoami) != "root" ]; then
    echo "Script must be run as root"
    exit 1
fi

echo "Enter password template"
read STR

for user in $(awk -F: '$7 ~ /(\/.*sh)/ { print $1 }' /etc/passwd)
do
    echo "${user},${STR}${user}"
    echo "${user}:${STR}${user}" | chpasswd
done