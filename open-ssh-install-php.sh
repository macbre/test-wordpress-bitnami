#!/bin/sh
apk update && \
	apk add php8-cli php8-mysqli && \
	ln -s /usr/bin/php8 /usr/bin/php && \
	php -v && php -m
