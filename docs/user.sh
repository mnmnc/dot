#!/bin/sh

xbps-install vim wget git p7zip rsync tree borg screen xtools xclip inetutils-telnet alsa-utils jq glances containers redshift
xbps-install mpv youtube-dl irssi gstreamer sxiv screenFetch ii rlwrap zathura zathura-pdf-poppler hub setroot
#xbps-install ruby sup

xbps-install libdvdcss libdvdread libdvdnav

xbps-install qutebrowser python3-PyQt5-webengine

useradd anon
passwd anon
usermod -G wheel -a anon
usermod -G audio -a anon
usermod -G cdrom -a anon

gpasswd -a anon audio

more /etc/passwd

# redshift service
# Create runit script
mkdir -p /etc/sv/redshift
cat >/etc/sv/redshift/run<<EOF
echo '#!/bin/sh' >> /etc/sv/redshift/run
echo 'exec redshift -c /etc/redshift.conf' >> /etc/sv/redshift/run
EOF
chmod +x /etc/sv/redshift/run
ln -s /run/runit/supervise.redshift /etc/sv/redshift/supervise
ln -s /etc/sv/redshift /var/service
