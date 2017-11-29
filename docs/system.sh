#!/bin/sh

xbps-install acpi lm_sensors ntfs-3g fuse-exfat lsof testdisk

#./xbps-src build ufraw
#./xbps-src install ufraw
#./xbps-src pkg ufraw
# xbps-install --repository=/home/anon/src/void-packages/hostdir/binpkgs ufraw

#/dev/snd/pcmC1D0c
#arecord -f cd -D hw:1,0 -d 20 test.wav
#aplay test.wav

# allow ping for non-root
chmod 4755 /bin/ping

cat >/etc/sysctl.d/01-disable-ipv6.conf<<EOF
net.ipv6.conf.all.disable_ipv6 = 1
EOF

cat >/etc/sysctl.d/02-dirty-ratio.conf<<EOF
vm.dirty_background_ratio = 5
vm.dirty_ratio = 10
vm.swappiness = 10
EOF

# autofs
xbps-install autofs
mkdir /data/mount
cat >/etc/autofs/auto.master<<EOF
/data/mount /etc/autofs/auto.drives --timeout=5,defaults,user,exec,uid=1000 --ghost
EOF
cat >/etc/autofs/auto.drives<<EOF
touro-drive -fstype=auto,sync :/dev/disk/by-uuid/5844216D44214F56
EOF
ln -s /etc/sv/autofs /var/service