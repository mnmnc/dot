xbps-install cups nmap cups-filters avahi #gutenprint
#xbps-remove -R avahi avahi-utils

./xbps-src build gutenprint
./xbps-src install gutenprint
./xbps-src pkg gutenprint
# xbps-install --repository=/home/anon/src/void-packages/hostdir/binpkgs gutenprint

# git rebase -i HEAD~3

# vim /etc/cups/cupsd.conf
#Browsing On
#BrowseAddress 192.168.2.*:631

cat >/etc/papersize<<EOT
a4
EOT

lpstat -s
lpadmin -d CanonPrinter

ln -s /etc/sv/cupsd /var/service

#http://192.168.2.104:631

#ln -s /etc/sv/avahi-daemon /var/service

#sudo nmap -sP 192.168.2.1/24

#http://192.168.2.105:631/ipp/printers/39132A-MB2300series

#http://192.168.2.105:631/printers/39132A000000

#http://192.168.2.105:631/ipp

#sudo xbps-remove -R foomatic-db-engine foomatic-db foomatic-db-nonfree

# http://gdlp01.c-wss.com/gds/5/0100006265/01/cnijfilter2-5.00-1-deb.tar.gz

#7z x cnijfilter2-5.00-1-deb.tar.gz
#7z x cnijfilter2-5.00-1-deb.tar

#7z x packages/cnijfilter2_5.00-1_i386.deb

#7z x data.tar ./usr/lib/cups/filter/cmdtocanonij2
#7z x data.tar ./usr/lib/cups/filter/rastertocanonij
#sudo cp usr/lib/cups/filter/* /usr/lib/cups/filter
#chmod +x /usr/lib/cups/filter/*canon*

#xbps-install autoconf libtool automake