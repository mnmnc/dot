#!/bin/sh

# ------------------------------
# System logging
# ------------------------------

xbps-install socklog-void
usermod -aG socklog <anon>
ln -s /etc/sv/socklog-unix /var/service/
ln -s /etc/sv/nanoklogd /var/service/

xbps-install cronie

ln -s /etc/sv/cronie /var/service/

xbps-install sysstat