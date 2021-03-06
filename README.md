A hardened NGINX image bundled with auto-renewal setup to get Letsencrypt certificates for multiple domains without aa downtime.

- Operating System: ubuntu:16.04
- Nginx Version: 1.13.1

Features
---------------------------------------------
- Restricted sudo access to run basic commands.
- Auto renewal of Letsencrypt certificates.
- Certificate validity checked every week as a cronjob and if required certificates renewed without service downtime.


Requirements
---------------------------------------------
- The respective domain configuration file should exist under,
    "<NGINX_INSTALL_DIR>/conf.d/<domain_name>.conf"

- The valid SSL certificates for domains should be existing under a specific directory structure with respective symbolic links as shown below (currently certificates are blank),

Certificates & Keys required PATH:
---------------------------------------------
- "<NGINX_INSTALL_DIR>/ssl/<domain_name>/live/fullchain.pem" 
- "<NGINX_INSTALL_DIR>/ssl/<domain_name>/live/privkey.pem"

Symbolic Links to Certificates & Keys:
---------------------------------------------
```sh
[user@server ~]# ln -s "<NGINX_INSTALL_DIR>/ssl/<domain_name>/live/fullchain.pem" "<NGINX_INSTALL_DIR>/ssl/<domain_name>/<domain_name>_fullchain.pem"

- [user@server ~]# ln -s "<NGINX_INSTALL_DIR>/ssl/<domain_name>/live/privkey.pem" "<NGINX_INSTALL_DIR>/ssl/<domain_name>/<domain_name>privkey.pem"
```

Note
---------------------------------------------
- Default password for root and nginxuser is "nginx". CHANGE IT!
- Default port is 80. To enable SSL, place the relevant certificates as shown in repo with 'example.com' sample.
