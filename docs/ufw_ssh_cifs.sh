#!/bin/sh

# ------------------------------
# UFW & SSH
# ------------------------------

xbps-install ufw

yes | ufw reset

# DNS Requests
ufw allow out 53/udp

# HTTP, HTTPS
ufw allow out 80,443/tcp

# SMTP & IMAP
ufw allow 25,143,587,993/tcp
ufw allow out 143,587,993/tcp

# IRC
#ufw allow out 194/tcp
ufw allow out 6660:7000/tcp

# Instant Messaging
ufw allow out 6667,1863,5222,5223,8010/tcp

# VOIP & file transfers
ufw allow out 6891:6900,6901/tcp

# SSH
ufw allow 2120/tcp
ufw allow out 2120/tcp

# Nginx (Http & https)
ufw allow 80,443/tcp

# Printer
ufw allow out 631/tcp

# Avahi
ufw allow out 5353/udp

# Hedgewars
ufw allow out 46631/tcp

# Samba
ufw allow 137,138,139,445/tcp

# Last rule: Blocks connections not allowed in rule set
ufw deny in to any
ufw deny out to any

# Allow ping
cat >>/etc/ufw/before.rules <<EOF
# allow outbound icmp
-A ufw-before-output -p icmp -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
-A ufw-before-output -p icmp -m state --state ESTABLISHED,RELATED -j ACCEPT
EOF

vim /etc/ufw/before.rules # edit COMMIT to the end

yes | ufw enable

# Gogs
#ufw allow in 3000/tcp
#ufw allow out 3000/tcp

# Cgit
#ufw allow in 8180/tcp
#ufw allow out 8180/tcp

# Minio
#ufw allow in 9190/tcp
#ufw allow out 9190/tcp

# ufw delete deny in to any

ln -s /etc/sv/ufw /var/service

mkdir -p ~/.ssh
chmod 600 ~/.ssh
touch ~/.ssh/authorized_keys

echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config
echo 'ChallengeResponseAuthentication no' >> /etc/ssh/sshd_config
echo 'PermitRootLogin no' >> /etc/ssh/sshd_config
echo 'Port 2120' >> /etc/ssh/sshd_config

ln -s /etc/sv/sshd /var/service

# CIFS
xbps-install cifs-utils
groupadd cifs
usermod -G cifs -a anon # Login again so group will be reloaded

# samba
xbps-install samba
groupadd smb
useradd <user>
smbpasswd -a <user>
cat >/etc/samba/smb.conf <<EOF
[global]
workgroup = smb
security = user
map to guest = Bad Password

[user-work]
path = /home/anon/usr/doc/wrk/user
writable = no
valid users = user
EOF

# mount -t cifs -o user=user //192.168.2.104/user-work /mnt/drive2/