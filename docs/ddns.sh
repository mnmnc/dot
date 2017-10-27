#!/bin/sh

# https://www.vultr.com/docs/how-to-setup-dynamic-dns

cd ~/dev

git clone https://github.com/andyjsmith/Vultr-Dynamic-DNS.git vultrddns && cd vultrddns

# edit config.json

xbps-install python-requests

# edit user crontab
# */30 * * * * python2.7 /home/<USER>/dev/vultrddns/ddns.py > /dev/null 2>&1