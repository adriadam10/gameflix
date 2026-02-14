#!/bin/bash
# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

log "Mounting remote library..."


mkdir -p "$ROM_DIR"
if ! is_mountpoint "$ROM_DIR"; then
    log "Mounting with WebCache..."
    # Ensure webcache is executable
    chmod +x "${SYSTEM_DIR}/webcache"
    
    # Run webcache
    "${SYSTEM_DIR}/webcache" --config "$WEBCACHE_CONF" --mountpoint "$ROM_DIR" --foreground > /dev/null 2>&1 &
    
    # Wait a bit for mount to happen
    sleep 2
    
    if is_mountpoint "$ROM_DIR"; then
        log "WebCache mounted successfully."
    else
        error "WebCache mount failed."
    fi
fi

log "Mount complete."
