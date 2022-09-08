#!/bin/sh
apk update && \
	apk add php8-cli && \
	ln -s /usr/bin/php8 /usr/bin/php && \
	php -v && php -m
