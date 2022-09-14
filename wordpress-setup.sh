#!/bin/bash

set -e  # Fail on error
set -u  # Treat unset variables as an error and exit immediately

echo "> wp-cli information"

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
