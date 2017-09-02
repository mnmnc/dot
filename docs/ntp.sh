#!/bin/sh

xbps-install ntp

ln -s /etc/sv/isc-ntpd /var/service