#!/bin/bash

set -e  # Fail on error
set -u  # Treat unset variables as an error and exit immediately

echo "> Installing PHP extensions and some utilities ..."

apk update && \
	apk add vim && \
	apk add php8-cli php8-mysqli && \
	ln -sf /usr/bin/php8 /usr/bin/php && \
	php -v && php -m

#
#
#

# Create a script that will set up env variables for all SSH sessions
# https://superuser.com/a/48787
echo "> Setting up env variables for database access ..."

SCRIPT_NAME='/config/.ssh/environment'

echo "# populates env variables for SSH sessions" > ${SCRIPT_NAME}
echo "WORDPRESS_DATABASE_NAME=${WORDPRESS_DATABASE_NAME}" >> ${SCRIPT_NAME}
echo "WORDPRESS_DATABASE_USER=${WORDPRESS_DATABASE_USER}" >> ${SCRIPT_NAME}
echo "WORDPRESS_DATABASE_PASSWORD=${WORDPRESS_DATABASE_PASSWORD}" >> ${SCRIPT_NAME}

# tweak sshd configuration // https://www.freebsd.org/cgi/man.cgi?sshd_config(5)

# allow ~/.ssh/environment file to set env variables
echo "PermitUserEnvironment yes" >> /etc/ssh/sshd_config

# and print the content of /etc/motd when logging in
echo "PrintMotd yes" >> /etc/ssh/sshd_config

#
#
#

echo "> Redirecting OpenSSH daemon logs to stderr ..."
echo "tail -f /config/logs/openssh/current >> /dev/stderr" > /sbin/logs_to_stderr.sh
sh /sbin/logs_to_stderr.sh &

#
#
#

# https://wp-cli.org/#installing
echo "> Installing wp-cli ..."
cd /tmp && \
	apk add php8-phar php8-mbstring php8-tokenizer && \
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	sudo mv wp-cli.phar /usr/local/bin/wp && \
	cd /opt/bitnami/wordpress && \
	wp --info

#
#
#
echo "> Enabling auto-updates so that the site is considered healthy by WordPress tools ..."

cd /opt/bitnami/wordpress && \
	wp config set WP_AUTO_UPDATE_CORE true --raw && \
	wp plugin auto-updates enable --all && \
	wp theme auto-updates enable --all

#
#
#
echo "> Setting WP_HOME and WP_SITEURL configs to '${WORDPRESS_SITE_URL}' ... "

cd /opt/bitnami/wordpress && \
	wp config set WP_HOME ${WORDPRESS_SITE_URL} && \
	wp config set WP_SITEURL ${WORDPRESS_SITE_URL} && \
	wp config get --format=dotenv | grep 'WP_'

#
#
#

echo "> Making the SSH user (id 1001) the owner of /opt/bitnami/wordpress and wp-config.php file ..."

chown -RP 1001 /opt/bitnami/wordpress/ /bitnami/wordpress/wp-config.php
