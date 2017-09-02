# Installing & setting up `nginx` with `fcgiwrap`

Install `nginx` & `fcgiwrap` normally visa `xbps-install`.
```sh
xbps-install nginx fcgiwrap
```

Create a `fcgiwrap` service file.
```sh
mkdir -p /etc/sv/fcgiwrap
echo '#!/bin/bash' >> /etc/sv/fcgiwrap/run
echo 'exec chpst -u nginx:nginx fcgiwrap -f -s unix:/tmp/fcgiwrap.sock' >> /etc/sv/fcgiwrap/run
chmod +x /etc/sv/fcgiwrap/run
ln -s /run/runit/supervise.fcgiwrap /etc/sv/fcgiwrap/supervise
```

Enable both `nginx` and `fcgiwrap`.
```sh
ln -s /etc/sv/fcgiwrap /var/service
ln -s /etc/sv/nginx /var/service
```

Create a `robots.txt`.
```sh
echo 'User-agent: *' > /usr/share/webapps/robots.txt
echo 'Disallow: /' >> /usr/share/webapps/robots.txt
```