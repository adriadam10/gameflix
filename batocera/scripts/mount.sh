#!/bin/bash
# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

log "Mounting remote library..."

[[ ! -f "$RCLONE_CONF" ]] && download_file "https://raw.githubusercontent.com/adriadam10/gameflix/main/rclone.conf" "$RCLONE_CONF"

mkdir -p "$ROM_DIR"
if ! mountpoint -q "$ROM_DIR"; then
    rclone mount myrient: "$ROM_DIR" \
        --http-no-head --no-checksum --no-modtime --attr-timeout 1000h \
        --dir-cache-time 1000h --poll-interval 1000h --allow-non-empty \
        --daemon --no-check-certificate --config="$RCLONE_CONF"
fi

log "Mount complete."
