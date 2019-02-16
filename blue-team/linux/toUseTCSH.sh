#!/bin/tcsh

# Check if user is root
if ( $EUID -ne 0 ) then
	printf "\nScript must be run as root\n"
	exit 1
endif

echo 'Enter the new password template:'
read -r passTemp
echo 'Confirm:'
read -r passConfirm

if ( -z "$passTemp" || "$passTemp" != "$passConfirm" ) then
	echo 'Invalid new password'
	exit 2
endif

for user in $(awk -F: '$7 ~ /(\/sh|\/bash)/ { print $1 }' /etc/passwd); do
	if ( $(id -u $user) -eq 0 ) then
		continue
	endif
	echo "Changing password for $user"
	newPass="$passTemp$delim$user"
	echo -e "$newPass\\n$newPass" | passwd "$user"
done
