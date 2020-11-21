#!/bin/ash

echo 'Enter passTemp: '
read -r passTemp
echo 'Confirm: '
read -r passConfirm

input="users.txt"
while IFS= read -r user
do
	echo "Changing password for $user"
	newPass="$passTemp"
	echo -e "$newPass\\n$newPass" | passwd "$user"
done < "$input"

