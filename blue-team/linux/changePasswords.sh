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

# prompt user for server info
read -p "Please enter the server IP: " serverIP
read -p "Please enter your username: " username 

# make backup folder if it doesn't exist
ssh "$username@$serverIP" mkdir -p "/home/$username/backup"
# call scp command on server’s backup folder
scp `hostname`.csv "$username@$serverIP:/home/backup"

rm `hostname`.csv
rm u.txt
rm lists.txt