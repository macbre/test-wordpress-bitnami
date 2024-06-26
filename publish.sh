#!/usr/bin/env bash
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

# -T disable pseudo-tty allocation
# https://developer.wordpress.org/cli/commands/post/create/
docker-compose -f ${DIRECTORY}/docker-compose.yml exec -T wordpress \
	wp post create --post_title="${TITLE}" --post_content="${CONTENT}" --post_status='publish' --porcelain | tee /tmp/post_id

set +x

POST_ID="$(cat /tmp/post_id)"

# attach a photo to the new post
# e.g. https://fastly.picsum.photos/id/828/450/150.jpg?hmac=AcD5dfz3UrPo15KUhXFzaxSWBrL7qQ13vbXWZsEaSAE
PHOTO_URL="$(curl -v 'https://picsum.photos/1280/500' 2>&1 | grep -i 'location:' | grep -Eo 'https[A-Za-z:/.0-9?=+-_]+')"

log "Uploading an image from <${PHOTO_URL}> and making it a featured image for #${POST_ID} post ..."

# https://developer.wordpress.org/cli/commands/media/import/
docker-compose -f ${DIRECTORY}/docker-compose.yml exec -T wordpress \
	wp media import "${PHOTO_URL}" \
		--title="Image" --caption="An image" --featured_image --post_id=${POST_ID} \

log "Done"
