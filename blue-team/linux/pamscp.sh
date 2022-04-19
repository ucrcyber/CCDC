#!/bin/bash
#prompt user for server info
read -p “Please enter the server IP: ” serverIP
read -p “Please enter your username: ” username 

#call scp command on server’s backup folder
scp -r ~/BackupLocal “$username@$serverIP:/var/backups”
