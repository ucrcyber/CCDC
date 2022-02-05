#!/bin/sh

# Disables the ability to load new modules
sudo sysctl -w kernel.modules_disabled=1
echo 'kernel.modules_disabled=1' | sudo tee /etc/sysctl.conf
