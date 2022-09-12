#!/bin/bash
set -eu

log() {
  msg=$1
  logger --tag 'wp-publish' --id --stderr $msg
}

SCRIPT=$(realpath "$0")
DIRECTORY=$(dirname "$SCRIPT")

log "Running in ${DIRECTORY}"

# https://linux.die.net/man/1/date
TITLE="A random $(date +%A) post at $(date +%r)"
CONTENT=$( curl -s 'https://baconipsum.com/api/?type=meat-and-filler' | jq -r .[0] )

log "Will post the following content as '${TITLE}': ${CONTENT}"

set -x
docker-compose -f ${DIRECTORY}/docker-compose.yml exec wordpress \
	wp post create --post_title="${TITLE}" --post_content="${CONTENT}" --post_status='publish'

set +x
log "Done"
