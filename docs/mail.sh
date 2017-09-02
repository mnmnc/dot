#!/bin/sh

# ------------------------------
# MAIL
# ------------------------------

xbps-install opensmtpd mailx

# https://www.opensmtpd.org/faq/example1.html
# https://www.opensmtpd.org/faq/config.html
useradd -m -c "Virtual Mail" -d /var/vmail -s /sbin/nologin vmail
chmod 600 /var/lib/acme/live/mail.<domain>/*
passwd vmail

#mkdir -m 700 /etc/smtpd/tls; cd /etc/smtpd/tls
#openssl req -new -x509 -nodes -newkey rsa:4096 -keyout smtpd.key -out smtpd.crt -days 1095
#chmod 400 smtpd.key; chmod 444 smtpd.crt

# /etc/smtpd/smtpd.conf

cat >/etc/smtpd/smtpd.conf <<EOF
pki mail.<domain> key "/var/lib/acme/live/mail.<domain>/privkey"
pki mail.<domain> certificate "/var/lib/acme/live/mail.<domain>/cert"

table aliases "/etc/aliases"

listen on eth0 port 25 hostname mail.<domain> tls pki mail.<domain>
listen on eth0 port 587 hostname mail.<domain> tls-require pki mail.<domain> auth mask-source

accept from any for domain "<domain>" alias <aliases> deliver to maildir "~/mails"

accept from local for any relay
EOF

cat >/etc/aliases <<EOF
mail: vmail
EOF

newaliases

ln -s /etc/sv/opensmtpd/ /var/service

# dovecot
xbps-install dovecot

#vim /etc/dovecot/conf.d/10-ssl.conf



# https://wiki.dovecot.org/Authentication/PasswordSchemes

# http://guillaumevincent.com/2015/01/31/OpenSMTPD-Dovecot-SpamAssassin.html

# inside /etc/dovecot/dovecot.conf
cat > /etc/dovecot/dovecot.conf <<EOF
protocols = imap
ssl = required
ssl_key = </var/lib/acme/live/mail.<domain>/privkey
ssl_cert = </var/lib/acme/live/mail.<domain>/cert
mail_location = maildir:~/mails
listen = *

userdb {
  driver = passwd
  args = blocking=no
}

passdb {
  driver = pam
  args = 
}
EOF

# https://wiki.dovecot.org/PasswordDatabase/PAM
cat >/etc/pam.d/dovecot <<EOF
auth    required        pam_unix.so nullok
account required        pam_unix.so
EOF

ln -s /etc/sv/dovecot /var/service

# spampd

xbps-install spampd