#!/bin/bash

if [ `whoami` != "root" ]; then
        echo "bro you already know why you're seeing this message"
        exit 1
fi

echo Ll9fICAgICAgICBfXyAgICAgICAgX19fLiAgIC5fXyAgICAgICAgICAgICAgICAgCnxfX3xfX19fX18vICB8X19fX19fIFxfIHxfXyB8ICB8ICAgX19fXyAgIF9fX19fXwp8ICBcX19fXyBcICAgX19cX18gIFwgfCBfXyBcfCAgfCBfLyBfXyBcIC8gIF9fXy8KfCAgfCAgfF8+ID4gIHwgIC8gX18gXHwgXF9cIFwgIHxfXCAgX19fLyBcX19fIFwgCnxfX3wgICBfXy98X198IChfX19fICAvX19fICAvX19fXy9cX>

ID_LIKE="$(cat /etc/*release | grep "ID_LIKE")"

if [[ ${ID_LIKE} = "ID_LIKE=debian" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"debian\"" ]]; then
        sudo apt-get install iptables -y
fi

elif [[ ${ID_LIKE} = "ID_LIKE=rhel fedora" ]] || [[ ${ID_LIKE} = "ID_LIKE=\"rhel fedora\"" ]]; then
        sudo yum install iptables
fi

else
        echo "This operating system is not supported"
        exit 1
fi

#echo Setting Timezone to America/Los_Angeles
#sudo timedatectl set-timezone America/Los_Angeles

sudo systemctl restart rsyslog

echo Setting Up IPV4
sudo iptables -F
sudo iptables -A INPUT -p tcp --dport 23 -j DROP
sudo iptables -X LOGGING
sudo iptables -N LOGGING
sudo iptables -A INPUT -j LOGGING
sudo iptables -A LOGGING -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j LOG --log-prefix "Incoming SSH Connection: " --log-level 7
sudo iptables -I OUTPUT -p tcp -m tcp --sport 22 -m state --state NEW,ESTABLISHED -j LOG --log-prefix "Outgoing SSH connection: " --log-level 7
sudo iptables -A LOGGING -j ACCEPT

echo Setting Up IPV6
sudo ip6tables -F
sudo ip6tables -X
sudo ip6tables -P INPUT DROP
sudo ip6tables -P OUTPUT DROP
sudo ip6tables -P FORWARD DROP



echo Script Done!

exit
