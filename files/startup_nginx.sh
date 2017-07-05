#!/bin/bash

sudo chown -R nginxuser:nginxuser ${NGINX_INSTALL_DIR} /home/${NGINXUSER} /var/cache/ /var/log/
sleep 7
sudo cron
sudo /etc/init.d/postfix start
sudo ln -s ~/letsencrypt_renew.sh /etc/cron.weekly/letsencrypt_renew.sh
sudo service nginx start
sleep infinity
