test-wordpress-bitnami
======================
[![Test containers](https://github.com/macbre/test-wordpress-bitnami/actions/workflows/ci.yml/badge.svg)](https://github.com/macbre/test-wordpress-bitnami/actions/workflows/ci.yml)

This repo contains the Docker Compose setup for [the Bitnami-powered WordPress instance](https://hub.docker.com/r/bitnami/wordpress/) with SSH access and `wp-cli` installed. Can [be run easily behind Traefik](https://github.com/macbre/test-wordpress-bitnami#behind-traefik-proxy). 

Once `docker compose up -d` is run (and the MySQL and WordPress is set up for the first time) you can:

```
curl 0.0.0.0:8888 -s | grep -i generator
```

## Customize

You can provide some env variables via `.env` file:

* `SSH_PASSWORD` (defaults to `p4ssw0rd`)
* `WORDPRESS_DATABASE_PASSWORD` (defaults to `p4ssw0rd`)
* `WORDPRESS_SITE_URL` (defaults to `http://localhost:8888`)
* `WORDPRESS_HOSTNAME` (used to add routing label for Traefik, e.g. `wptest.myself.dev`)
* `WORDPRESS_HTTP_PORT` (defaults to `8888`)

> You can use `head -c 500 /dev/urandom | md5 | base64` to generate them.

## `wp-cli`

[`wp-cli` tool](https://wp-cli.org/) is installed in both WordPress and SSH containers.

```
$ docker-compose exec ssh-dev wp post list
+----+--------------+-------------+---------------------+-------------+
| ID | post_title   | post_name   | post_date           | post_status |
+----+--------------+-------------+---------------------+-------------+
| 1  | Hello world! | hello-world | 2022-09-08 11:55:08 | publish     |
+----+--------------+-------------+---------------------+-------------+
```

## Automated posts publishing

Call `./publish.sh` from your crontab:

```
17 */4 *   *   *     /path/to/publish.sh 2>&1 | tee -a $HOME/publish.log
```

> Make sure `$PATH` is properly set up in the crontab.

## Debugging 

You can access the running WordPress container via:

```
docker compose exec -i wordpress bash
```

And use SSH to get access to the WordPress file:

```
ssh wordpress@0.0.0.0 -p62222 -i ssh_key

openssh-server:~$ ls -lh /opt/bitnami/wordpress | grep '/bitnami'
lrwxrwxrwx  1 wordpress root        32 Sep 13 12:08 wp-config.php -> /bitnami/wordpress/wp-config.php
lrwxrwxrwx  1 wordpress root        29 Sep 13 12:08 wp-content -> /bitnami/wordpress/wp-content
```

## Files and permissions

* The WordPress instance is located at `/opt/bitnami/wordpress`.
* WordPress files are owned by `wordpress(1001):root`.

## Regenerate OpenSSH public key

```
ssh-keygen -t ed25519 -f ssh_key -N ''
```

## Behind Traefik proxy

This container is ready [to be put behind Traefik](https://github.com/macbre/docker-traefik).

1. [Clone the repo](https://github.com/macbre/docker-traefik) and run the Traefik container. 
2. Change your WordPress install to use https:

```
WORDPRESS_HTTP_PORT=8181
WORDPRESS_SITE_URL="https://<your domain, e.g. test.myself.dev>/"
WORDPRESS_HOSTNAME=<your domain, e.g. test.myself.dev>
```

3. The requests reaching your WordPress container will be using HTTP (TLS is terminated at the Traefik level). So make sure to pretent that WordPress is handling https requests to avoid redirect loops:

```php
// Add this to your wp-config.php
// ...
// fix redirects loope when accessing /wp-admin and wp-login.php
// https://wordpress.stackexchange.com/questions/170288/force-ssl-admin-not-working
define('FORCE_SSL_ADMIN', true);

// a comma-separated list e.g. http,https
if (strpos($_SERVER['HTTP_X_FORWARDED_PROTO'], 'https') !== false) {
       $_SERVER['HTTPS']='on';
}

/* That's all, stop editing! Happy publishing. */
```
