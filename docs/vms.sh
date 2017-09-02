#!/bin/sh

xbps-install qemu aqemu
usermod -aG kvm <USERNAME>
modprobe kvm-intel

# logoff and logon again