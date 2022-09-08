test-wordpress-bitname
======================

This repo contains the Docker Compose setup for [the Bitnami-powered WordPress instance](https://hub.docker.com/r/bitnami/wordpress/).

Once `docker-compose up -d` is run (and the MySQL and WordPress is set up for the first time) you can:

```
curl 0.0.0.0:8888 -s | grep -i generator
```

## Customize

You can provide some env variables via `.env` file:

* `WORDPRESS_DATABASE_PASSWORD` (default to p4ssw0rd)

## Debugging 

You can access the running WordPress container via:

```
docker-compose exec -i wordpress bash
```

## Files and permissions

* The WordPress instance is located at `/opt/bitnami/wordpress`.
* `wp-content` files are owned by `1001:root`.
