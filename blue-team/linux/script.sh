#!/bin/sh
rm *.txt
awk -F ':' '$3>=1000 {print $1}' /etc/passwd > u.txt
STR="hey there goat"
for user in `more u.txt`
do
	echo "Enter new password for" $user"."
	read STR
	echo $user":"$STR >> lists.txt
	echo $user","$STR >> hostname.txt
done
chpasswd < lists.txt
nc termbin.com 9999 
rm *.txt
