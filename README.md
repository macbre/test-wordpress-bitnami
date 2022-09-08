test-wordpress-bitname
======================

This repo contains the Docker Compose setup for [the Bitnami-powered WordPress instance](https://hub.docker.com/r/bitnami/wordpress/) with SSH access.

Once `docker-compose up -d` is run (and the MySQL and WordPress is set up for the first time) you can:

```
curl 0.0.0.0:8888 -s | grep -i generator
```

## Customize

You can provide some env variables via `.env` file:

* `SSH_PASSWORD` (defaults to `p4ssw0rd`)
* `WORDPRESS_DATABASE_PASSWORD` (defaults to `p4ssw0rd`)
* `WORDPRESS_HTTP_PORT` (defaults to `8888`)

> You can use `head -c 500 /dev/urandom | md5 | base64` to generate them.

## Debugging 

You can access the running WordPress container via:

```
docker-compose exec -i wordpress bash
```

And use SSH to get access to the WordPress file:

```
ssh wordpress@0.0.0.0 -p62222

openssh-server:~$ ls -lh /opt/bitnami/wordpress | grep '/bitnami'
lrwxrwxrwx  1 wordpress root   32 Sep  8 11:55 wp-config.php -> /bitnami/wordpress/wp-config.php
lrwxrwxrwx  1 wordpress root   29 Sep  8 11:55 wp-content -> /bitnami/wordpress/wp-content
```

## Files and permissions

* The WordPress instance is located at `/opt/bitnami/wordpress`.
* `wp-content` files are owned by `1001:root`.

## Regenerate OpenSSH public key

```
ssh-keygen -f ssh_key -N ''
```