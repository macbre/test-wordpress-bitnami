#!/bin/sh
echo "> Installing PHP extensions ..."

apk update && \
	apk add php8-cli php8-mysqli && \
	ln -s /usr/bin/php8 /usr/bin/php && \
	php -v && php -m

#
#
#

# Create a script that will set up env variables for all SSH sessions
# https://superuser.com/a/48787
echo "> Setting up env variables for database access ..."

SCRIPT_NAME='/config/.ssh/environment'

echo "WORDPRESS_DATABASE_NAME=${WORDPRESS_DATABASE_NAME}" >> ${SCRIPT_NAME}
echo "WORDPRESS_DATABASE_USER=${WORDPRESS_DATABASE_USER}" >> ${SCRIPT_NAME}
echo "WORDPRESS_DATABASE_PASSWORD=${WORDPRESS_DATABASE_PASSWORD}" >> ${SCRIPT_NAME}

cat ${SCRIPT_NAME}

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