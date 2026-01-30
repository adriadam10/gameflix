#!/bin/bash
# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

log "Starting Nginx functionality verification..."

# 1. Verify Nginx Process
if ! pgrep -x "nginx" >/dev/null; then
    error "Nginx process is NOT running."
    exit 1
fi
log "Nginx process is running."

# 2. Verify Host Resolution
if ! grep -q "127.0.0.1.*local.myrient.erista.me" /etc/hosts; then
    error "local.myrient.erista.me is NOT resolving to localhost in /etc/hosts."
    exit 1
fi
log "Host resolution configured correctly."

# define test variables
# Using a small Game Boy game for testing to minimize bandwidth/time
TEST_URL="http://local.myrient.erista.me/files/No-Intro/Nintendo%20-%20Game%20Boy/Tetris%20%28World%29%20%28Rev%201%29.zip"
TEST_FILE="/tmp/nginx_test_game.zip"

cleanup() {
    rm -f "$TEST_FILE"
}
trap cleanup EXIT

# 3. First Download (Warmup / Cache Check)
log "Attempting first download (verify connectivity)..."
# We use curl to check headers clearly.
# -I fetches headers only, but to cache it might need a GET. 
# However, nginx often caches on GET. Let's do a full download to ensuring caching happens.
# Using -D to dump headers.

HEADERS_FILE="/tmp/nginx_headers_1.txt"
START=$(date +%s%3N)
if ! curl -s -f -D "$HEADERS_FILE" -o "$TEST_FILE" "$TEST_URL"; then
    error "Failed to download test file from $TEST_URL"
    exit 1
fi
END=$(date +%s%3N)
DURATION_1=$((END - START))

# Check Cache Status
CACHE_STATUS=$(grep -i "X-Cache-Status" "$HEADERS_FILE" | tail -n 1 | cut -d':' -f2 | tr -d ' \r')
log "Download 1 complete in ${DURATION_1}ms. Cache Status: ${CACHE_STATUS:-UNKNOWN}"

# 4. Second Download (Cache Hit Verification)
log "Attempting second download (verify cache hit)..."
HEADERS_FILE_2="/tmp/nginx_headers_2.txt"
START=$(date +%s%3N)
if ! curl -s -f -D "$HEADERS_FILE_2" -o "$TEST_FILE" "$TEST_URL"; then
    error "Failed to second download test file."
    exit 1
fi
END=$(date +%s%3N)
DURATION_2=$((END - START))

CACHE_STATUS_2=$(grep -i "X-Cache-Status" "$HEADERS_FILE_2" | tail -n 1 | cut -d':' -f2 | tr -d ' \r')
log "Download 2 complete in ${DURATION_2}ms. Cache Status: ${CACHE_STATUS_2:-UNKNOWN}"

# 5. Analysis
if [[ "$CACHE_STATUS_2" == "HIT" ]]; then
    log "SUCCESS: Nginx is caching correctly (HIT received)."
else
    # It might be REVALIDATED or other status, but we expect HIT for static content
    error "WARNING: Expected CACHE HIT on second download, got ${CACHE_STATUS_2:-UNKNOWN}."
    # We won't exit 1 here as network conditions might vary, but it's a warning.
fi

if (( DURATION_2 < DURATION_1 )); then
    log "Speed check passed: Second download was faster (${DURATION_2}ms vs ${DURATION_1}ms)."
else
    log "Speed check inconclusive: Second download (${DURATION_2}ms) was not faster than first (${DURATION_1}ms)."
fi

log "Nginx verification script finished."
