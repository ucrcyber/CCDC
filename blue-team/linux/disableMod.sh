#!/bin/sh

if [ $(whoami) != "root" ]; then
    echo "Script must be run as root"
    exit 1
fi

# Disables the ability to load new modules
sysctl -w kernel.modules_disabled=1
echo 'kernel.modules_disabled=1' > /etc/sysctl.conf
