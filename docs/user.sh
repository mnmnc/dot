#!/bin/sh

xbps-install vim wget git p7zip rsync tree borg screen xtools xclip inetutils-telnet alsa-utils jq glances containers
xbps-install mpv youtube-dl irssi tabbed gstreamer sxiv screenFetch go-ipfs ii zathura zathura-pdf-poppler

xbps-install qutebrowser python3-PyQt5-webengine

useradd anon
passwd anon
usermod -G wheel -a anon
usermod -G audio -a anon

gpasswd -a anon audio

more /etc/passwd