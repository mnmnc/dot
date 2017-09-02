#!/bin/sh

xbps-install cifs-utils dhclient
mkdir /host
groupadd cifs
usermod -G cifs -a anon # Login again so group will be reloaded
echo "//192.168.2.105/VoidLinux /host cifs _netdev,gid=cifs,credentials=/etc/win.cred 0 0" >> /etc/fstab
echo "username=<USER>" >> /etc/win.cred
echo "password=<PASS>" >> /etc/win.cred
mount -a
mount