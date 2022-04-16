#!/bin/sh
echo "Enter password template"
read STR

for user in $(awk -F: '$7 ~ /(\/.*sh)/ { print $1 }' /etc/passwd)
do
    echo "${user},${user}${STR}"
    echo "${user}:${user}${STR}" | chpasswd
done