#!/bin/sh

# ------------------------------
# nginx + fcgiwrap
# ------------------------------

xbps-install nginx fcgiwrap

# Create runit script
mkdir -p /etc/sv/fcgiwrap
echo '#!/bin/bash' >> /etc/sv/fcgiwrap/run
echo 'exec chpst -u nginx:nginx fcgiwrap -f -s unix:/tmp/fcgiwrap.sock' >> /etc/sv/fcgiwrap/run
chmod +x /etc/sv/fcgiwrap/run
ln -s /run/runit/supervise.fcgiwrap /etc/sv/fcgiwrap/supervise

ln -s /etc/sv/fcgiwrap /var/service
ln -s /etc/sv/nginx /var/service

# robots.txt
echo 'User-agent: *' > /usr/share/webapps/robots.txt
echo 'Disallow: /' >> /usr/share/webapps/robots.txt

# http://nginx.org/en/docs/http/ngx_http_limit_req_module.html#limit_req
vim /etc/nginx/nginx.conf
http {
    limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;
    limit_req zone=one burst=3;

# ------------------------------
# gogs
# ------------------------------
xbps-install gogs

chown gogs:gogs /srv/gogs

sqlite3 /srv/gogs/data/db.sqlite # .quit

ln -s /etc/sv/gogs /var/service

chown gogs:gogs /etc
# visit http://<IP>:3000/install
chown root:root /etc

# -----------------------------
# cgit
# -----------------------------

xbps-install cgit

# Configure using https://wiki.archlinux.org/index.php/Cgit#Nginx
vim /etc/nginx/nginx.conf
  server {
    listen                80;
    server_name           git.<DOMAIN>;
    root                  /usr/share/webapps/cgit;
    try_files             $uri @cgit;

    location @cgit {
      include             fastcgi_params;
      fastcgi_param       SCRIPT_FILENAME $document_root/cgit.cgi;
      fastcgi_param       PATH_INFO       $uri;
      fastcgi_param       QUERY_STRING    $args;
      fastcgi_param       HTTP_HOST       $server_name;
      fastcgi_pass        unix:/tmp/fcgiwrap.sock;
    }
  }

echo 'scan-path=/srv/git/' >> /etc/cgitrc
mkdir -p /srv/git

# -----------------------------
# minio
# -----------------------------

# https://docs.minio.io/docs/setup-nginx-proxy-with-minio

wget https://dl.minio.io/server/minio/release/linux-amd64/minio -O /usr/bin/minio

chmod +x /usr/bin/minio

mkdir -p /data/acd
chown nginx:nginx /data/acd

mkdir -p /etc/sv/minio
echo '#!/bin/bash' >> /etc/sv/minio/run
echo 'exec chpst -u nginx:nginx minio server /data/acd' >> /etc/sv/minio/run
chmod +x /etc/sv/minio/run
ln -s /run/runit/supervise.minio /etc/sv/minio/supervise

ln -s /etc/sv/minio /var/service

#mkdir -p /home/nginx/.minio/certs
#ln -s /var/lib/acme/live/cron.world/privkey /home/nginx/.minio/certs/private.key
#ln -s /var/lib/acme/live/cron.world/cert /home/nginx/.minio/certs/public.crt

# -------------------------------
# ssl
# -------------------------------

# https://letsencrypt.org/getting-started/

#wget https://dl.eff.org/certbot-auto -O /usr/bin/certbot-auto
#chmod +x /usr/bin/certbot-auto

# https://hlandau.github.io/acme/
xbps-install acmetool

# configure nginx
# https://hlandau.github.io/acme/userguide#web-server-configuration-challenges

vim /etc/nginx/nginx.conf
# add to /etc/nginx/nginx.conf
   upstream acmetool {
    server 127.0.0.1:4402;
  }

  server {
    listen                80;

    location /.well-known/acme-challenge/ {
      proxy_pass http://acmetool;
    }
  }

sv restart nginx

acmetool quickstart # 1, 2, Y
DOMAIN="<domain>"
acmetool want "${DOMAIN}" "www.${DOMAIN}" "git.${DOMAIN}" "minio.${DOMAIN}" "mail.${DOMAIN}"

ls /var/lib/acme/live/*/

# http://nginx.org/en/docs/http/configuring_https_servers.html

