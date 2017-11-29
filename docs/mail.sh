#!/bin/sh

# ------------------------------
# MAIL
# ------------------------------

xbps-install opensmtpd mailx spampd

# https://www.opensmtpd.org/faq/example1.html
# https://www.opensmtpd.org/faq/config.html
useradd -m -c "Virtual Mail - Public" -d /var/mail/pub -s /sbin/nologin vmail-pub
passwd vmail-pub

useradd -m -c "Virtual Mail - Private" -d /var/mail/prv -s /sbin/nologin vmail-prv
passwd vmail-prv

useradd -m -c "Virtual Mail - Direct" -d /var/mail/dct -s /sbin/nologin vmail-dct
passwd vmail-dct

chmod 600 /var/lib/acme/live/mail.<domain>/*

#mkdir -m 700 /etc/smtpd/tls; cd /etc/smtpd/tls
#openssl req -new -x509 -nodes -newkey rsa:4096 -keyout smtpd.key -out smtpd.crt -days 1095
#chmod 400 smtpd.key; chmod 444 smtpd.crt

# /etc/smtpd/smtpd.conf

cat >/etc/smtpd/smtpd.conf <<EOF
pki mail.<domain> key "/var/lib/acme/live/mail.<domain>/privkey"
pki mail.<domain> certificate "/var/lib/acme/live/mail.<domain>/cert"

table aliases "/etc/smtpd/aliases"
table creds "/etc/smtpd/creds"
table vdoms "/etc/smtpd/vdoms"
table vusers "/etc/smtpd/vusers"

listen on lo port 10026 tag Filtered

listen on eth0 port 25 hostname mail.<domain> tls pki mail.<domain>
listen on eth0 port 587 hostname mail.<domain> tls-require pki mail.<domain> auth mask-source

accept tagged Filtered for domain <vdoms> alias <aliases> deliver to maildir "~/mails"

accept from any for domain <vdoms> relay via "smtp://127.0.0.1:10025"

accept from local for any relay
EOF

#cat >/etc/smtpd/creds <<EOF
#vmail: $(smtpctl encrypt)
#EOF

cat >/etc/smtpd/vusers <<EOF
EOF

cat >/etc/smtpd/vdoms <<EOF
<domain>
EOF

cat >/etc/smtpd/aliases <<EOF
abuse: mail
postmaster: mail
contact: mail

mail: vmail-pub
EOF

# https://wiki.archlinux.org/index.php/OpenSMTPD

# smtpctl encrypt

newaliases

ln -s /etc/sv/spamd/ /var/service # spamassasin
ln -s /etc/sv/spampd/ /var/service # sa-wrapper
ln -s /etc/sv/opensmtpd/ /var/service # smtpd

# dovecot
xbps-install dovecot

#vim /etc/dovecot/conf.d/10-ssl.conf

#POP 110
#IMAP 143
#SMTP (25 / Alternativ 587) - Authentifzierung erforderlich

#SSL POP 995
#SSL IMAP 993
#SSL SMTP 465 - Authentifzierung erforderlich
#TLS POP 110
#TLS IMAP 143
#TLS SMTP (25 / Alternativ 587) - Authentifzierung erforderlich

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