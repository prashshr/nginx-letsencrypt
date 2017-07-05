A hardened NGINX image bundled with auto-renewal setup without downtime to get Letsencrypt certificates for multiple domains.

Operating System: ubuntu:16.04
Nginx Version: 1.13.1

Features
---------------------------------------------
- Restricted sudo access to run basic commands.
- Auto renewal of Letsencrypt certificates.
- Certificate validity checked every week as a cronjob and if required certificates renewed without service downtime.


Requirements
---------------------------------------------
- The respective domain configuration file should exist under,
    "<NGINX_INSTALL_DIR>/conf.d/<domain_name>.conf"

- The valid SSL certificates for domains should exist under following directory structure with respective symbolic links as shown below,

Certificates & Keys:
---------------------------------------------
"<NGINX_INSTALL_DIR>/ssl/<domain_name>/live/fullchain.pem", 
"<NGINX_INSTALL_DIR>/ssl/<domain_name>/live/privkey.pem"

Symbolic Links to Certificates & Keys:
---------------------------------------------
[user@server ~]# ln -s "<NGINX_INSTALL_DIR>/ssl/<domain_name>/live/fullchain.pem" "<NGINX_INSTALL_DIR>/ssl/<domain_name>/<domain_name>_fullchain.pem"

[user@server ~]# ln -s "<NGINX_INSTALL_DIR>/ssl/<domain_name>/live/privkey.pem" "<NGINX_INSTALL_DIR>/ssl/<domain_name>/<domain_name>privkey.pem"


Note
---------------------------------------------
- Default password for root and nginxuser is "nginx". CHANGE IT!
- Default port is 80. To enable SSL, place the relevant certificates as mentioned above and as 'example.com' sample in the image.
