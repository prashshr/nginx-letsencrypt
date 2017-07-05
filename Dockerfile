FROM debian:stretch-slim

# Change the email address
MAINTAINER NGINX Docker Letsencrypt "prash.shr@gmail.com"

ENV NGINX_VERSION 1.13.1-1~stretch
ENV NJS_VERSION   1.13.1.0.1.10-1~stretch

ENV NGINXUSER nginxuser
ENV NGINXUSERID 752
ENV NGINXGRPID 752
ENV NGINX_INSTALL_DIR /etc/nginx

ENV TIMEZONE Europe/Berlin

# Change the email address
ENV LETSENCRYPT_ADMIN_EMAIL prash.shr@gmail.com

RUN apt-get update && apt-get install sudo git cron bc tzdata -y
RUN apt-get install --reinstall procps -y

RUN apt-get update \
	&& apt-get install --no-install-recommends --no-install-suggests -y gnupg1 \
	&& \
	NGINX_GPGKEY=573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62; \
	found=''; \
	for server in \
		ha.pool.sks-keyservers.net \
		hkp://keyserver.ubuntu.com:80 \
		hkp://p80.pool.sks-keyservers.net:80 \
		pgp.mit.edu \
	; do \
		echo "Fetching GPG key $NGINX_GPGKEY from $server"; \
		apt-key adv --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$NGINX_GPGKEY" && found=yes && break; \
	done; \
	test -z "$found" && echo >&2 "error: failed to fetch GPG key $NGINX_GPGKEY" && exit 1; \
	apt-get remove --purge -y gnupg1 && apt-get -y --purge autoremove && rm -rf /var/lib/apt/lists/* \
	&& echo "deb http://nginx.org/packages/mainline/debian/ stretch nginx" >> /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get install --no-install-recommends --no-install-suggests -y \
						nginx=${NGINX_VERSION} \
						nginx-module-xslt=${NGINX_VERSION} \
						nginx-module-geoip=${NGINX_VERSION} \
						nginx-module-image-filter=${NGINX_VERSION} \
						nginx-module-njs=${NJS_VERSION} \
						gettext-base \
	&& rm -rf /var/lib/apt/lists/*

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install postfix mailutils -y

RUN groupadd -g ${NGINXUSERID} ${NGINXUSER} && useradd -r -s /bin/bash -d /home/${NGINXUSER}  -u ${NGINXGRPID}  -g ${NGINXUSER}  -m ${NGINXUSER} 
RUN echo "${NGINXUSER}:sasfEQPt9v8hg" | chpasswd && echo "root:sasfEQPt9v8hg" | chpasswd

RUN git clone https://github.com/letsencrypt/letsencrypt /tmp/letsencrypt 

RUN chown ${NGINXUSER}:${NGINXUSER} /home/${NGINXUSER} /tmp/letsencrypt

RUN /tmp/letsencrypt/letsencrypt-auto --os-packages-only -q

RUN rm /etc/localtime && ln -s /usr/share/zoneinfo/${TIMEZONE}/etc/localtime
RUN dpkg-reconfigure -f noninteractive tzdata

COPY files/letsencrypt_renew.sh /home/${NGINXUSER}/ 
COPY files/sudoers_nginx /etc/sudoers
COPY files/startup_nginx.sh /home/${NGINXUSER}/

ADD conf.d ${NGINX_INSTALL_DIR}/conf.d
ADD ssl ${NGINX_INSTALL_DIR}/ssl
RUN rm -f ${NGINX_INSTALL_DIR}/conf.d/default.conf

USER ${NGINXUSER} 
WORKDIR /home/${NGINXUSER} 

CMD ["./startup_nginx.sh"]
