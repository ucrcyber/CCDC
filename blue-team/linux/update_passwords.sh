#!/bin/sh
# change password for users 
grep "/home" /etc/passwd | awk -F: '{print $1}' > users.txt
while read user; do
	echo "$user@123" | passwd --stdin "$user"
done < users.txt

