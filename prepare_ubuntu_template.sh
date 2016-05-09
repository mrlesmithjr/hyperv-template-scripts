#!/bin/bash

#grab Ubuntu Codename
codename="$(lsb_release -c | awk {'print $2}')"

#update apt-cache
apt-get update

#Preparing and installing Hyper-V kernel packages
apt-get install linux-virtual

#Installing Hyper-V tools
apt-get install linux-tools-virtual linux-cloud-tools-virtual

#Stop services for cleanup
service rsyslog stop

#clear audit logs
if [ -f /var/log/audit/audit.log ]; then
    cat /dev/null > /var/log/audit/audit.log
fi
if [ -f /var/log/wtmp ]; then
    cat /dev/null > /var/log/wtmp
fi
if [ -f /var/log/lastlog ]; then
    cat /dev/null > /var/log/lastlog
fi

#cleanup persistent udev rules
if [ -f /etc/udev/rules.d/70-persistent-net.rules ]; then
    rm /etc/udev/rules.d/70-persistent-net.rules
fi

#cleanup /tmp directories
rm -rf /tmp/*
rm -rf /var/tmp/*

#cleanup current ssh keys
rm -f /etc/ssh/ssh_host_*

#add check for ssh keys on reboot...regenerate if neccessary
sed -i -e 's|exit 0||' /etc/rc.local
sed -i -e 's|.*test -f /etc/ssh/ssh_host_dsa_key.*||' /etc/rc.local
bash -c 'echo "test -f /etc/ssh/ssh_host_dsa_key || dpkg-reconfigure openssh-server" >> /etc/rc.local'
bash -c 'echo "exit 0" >> /etc/rc.local'

#reset hostname
cat /dev/null > /etc/hostname

#cleanup apt
apt-get clean

#cleanup shell history
history -w
history -c
