#!/bin/bash

NGINXUSER=nginxuser
NGINXUSER_HOMEDIR=/home/nginxuser
NGINX_INSTALL_DIR=/etc/nginx
NGINX_SSL_DIR=${NGINX_INSTALL_DIR}/ssl
NGINX_CONF_DIR=${NGINX_INSTALL_DIR}/conf.d
LETSENCRYPT_CONF_DIR=${NGINXUSER_HOMEDIR}
LETSENCRYPT_LOGS_DIR=${NGINXUSER_HOMEDIR}
LETSENCRYPT_WORK_DIR=${NGINXUSER_HOMEDIR}
LETSENCRYPT_INSTALL_DIR=/tmp/letsencrypt
LETSENCRYPT_ADMIN_EMAIL=prashant.sharma@hitabis.de

for a in `cd ${NGINX_INSTALL_DIR}/conf.d/; ls *.conf | sed 's/.conf//g'`
do
        DOMAIN_DIR=$(ls ${NGINX_SSL_DIR} 2>&1 | grep -x "$a")
        DOMAIN_CONF=$(ls ${NGINX_CONF_DIR} 2>&1 | grep -x "$a.conf")

        # Checking whether configuration file and ssl certificates directory exists  with a exact domainname in Nginx config.
        if [ -e ${NGINX_CONF_DIR}/${DOMAIN_CONF} ] &&  [ -d ${NGINX_SSL_DIR}/${DOMAIN_DIR} ]; then

        CERT_FILE=${NGINX_SSL_DIR}/$a/${a}_fullchain.pem
        EXP_LIMIT=30;

        DATE_NOW=$(date -d "now" +%s)
        EXP_DATE=$(date -d "`openssl x509 -in $CERT_FILE -text -noout | grep "Not After" | cut -c 25-`" +%s)
        EXP_DAYS=$(echo \( $EXP_DATE - $DATE_NOW \) / 86400 | bc)

        echo "Checking expiration date for $a...."

                if [ "$EXP_DAYS" -gt "$EXP_LIMIT" ] ; then
                        echo "The certificate is up to date, no need for renewal (More than $EXP_LIMIT days left)."
                        echo "$a SSL certificate is up-to-date, expires on $EXP_DATE. NO need for renewal (More than $EXP_LIMIT days left`date +%F-%H%M`" | mail -s "$a SSL Certificate Expiry Check" $LETSENCRYPT_ADMIN_EMAIL
                else
                        echo "The certificate for $a is about to expire in less than $EXP_LIMIT days. Starting renewal script..."
                        mkdir ${NGINX_SSL_DIR}/$a/oldcerts_`date +%d%m%y`; echo "Created ${NGINX_SSL_DIR}/$a/oldcerts_`date +%d%m%y`"
                        cp -rHp ${NGINX_SSL_DIR}/$a/live/*.* ${NGINX_SSL_DIR}/$a/oldcerts_`date +%d%m%y`/     2>&1
                        echo "Copied Old certificates from ${NGINX_SSL_DIR}/$a/live/* to ${NGINX_SSL_DIR}/$a/oldcerts_`date +%d%m%y`/"
                        echo "Requesting letsencrypt certificate for $a.."
                        sudo chown -R ${NGINXUSER}:${NGINXUSER} ${LETSENCRYPT_CONF_DIR} ${LETSENCRYPT_LOGS_DIR} ${LETSENCRYPT_WORK_DIR} ${LETSENCRYPT_INSTALL_DIR} /var/log/
                        if [ `echo $a| awk -F'.' '{ print NF-1 }'` -eq 1 ] ; then
                                echo "Requesting certificates for $a and www.${a}"
                                ${LETSENCRYPT_INSTALL_DIR}/letsencrypt-auto certonly  \
                                --nginx  \
                                --agree-tos  \
                                --logs-dir ${LETSENCRYPT_LOGS_DIR}  \
                                --config-dir ${LETSENCRYPT_CONF_DIR}  \
                                --work-dir ${LETSENCRYPT_WORK_DIR}  \
                                --email ${LETSENCRYPT_ADMIN_EMAIL}   \
                                --non-interactive  \
                                -d www.${a}  \
                                -d.${a}
                        else
                                echo "Requesting certificates for $a "
                                ${LETSENCRYPT_INSTALL_DIR}/letsencrypt-auto certonly  \
                                --nginx  \
                                --agree-tos  \
                                --logs-dir ${LETSENCRYPT_LOGS_DIR}  \
                                --config-dir ${LETSENCRYPT_CONF_DIR}  \
                                --work-dir ${LETSENCRYPT_WORK_DIR}  \
                                --email ${LETSENCRYPT_ADMIN_EMAIL}   \
                                --non-interactive  \
                                -d ${a}
                        fi
                echo "copying new certificates to $a nginx ssl config"
		sudo chown -R ${NGINXUSER}:${NGINXUSER} ${LETSENCRYPT_CONF_DIR} ${LETSENCRYPT_LOGS_DIR} ${LETSENCRYPT_WORK_DIR} ${LETSENCRYPT_INSTALL_DIR} /var/log/
                sudo cp -H ${LETSENCRYPT_WORK_DIR}/live/$a/* ${NGINX_INSTALL_DIR}/ssl/$a/live/
                sudo service nginx reload
                echo "Renewal process finished for domain $a"
                echo "SSL certificate for domain $a has been successfully renewed. It was about to expire on $EXP_DATE. KINDLY TRY TO ACCESS THE DOMAIN AND CHECK VALIDITY MANUALLY" | mail -s "$a SSL Certificate Renewed" $LETSENCRYPT_ADMIN_EMAIL
                fi
        else
echo -e "Invalid Domain name. Before attempting SSL certificate request make sure '<domain_name>.conf' nginx configuration exists under ${NGINX_CONF_DIR}/ and the valid certificates under ${NGINX_SSL_DIR}/<domain_name>/\nUsage:letsencrypt_renew.sh <domain_name>"
        fi
done
