#! /bin/bash

sudo apt-get update
sudo apt-get install clamav clamav-daemon
echo "installed clamav!"
clamscan --version

echo "stopping clamav-freshclam service..."
sudo service clamav-freshclam stop
echo "updating signature database..."
sudo freshclam

echo "moving daily.cvd to /var/lib/clamav/..."
sudo mkdir /var/lib/clamav
cp daily.cvd /var/lib/clamav/daily.cvd

echo "starting up clamav..."
sudo service clamav-freshclam start
