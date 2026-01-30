#!/bin/bash
# shellcheck disable=SC2034

# --- Shared Variables ---
USERDATA="/userdata"
SYSTEM_DIR="${USERDATA}/system"
ROM_DIR="${USERDATA}/rom"
ROMS_BASE_DIR="${USERDATA}/roms"
THUMB_DIR="${USERDATA}/thumb"
THUMBS_BASE_DIR="${USERDATA}/thumbs"
CACHE_DIR="${SYSTEM_DIR}/.cache"
NGINX_DIR="${SYSTEM_DIR}/nginx"
RCLONE_CONF="${SYSTEM_DIR}/rclone.conf"
HOSTS_ENTRY="127.0.0.1 local.myrient.erista.me"
PLATFORMS_URL="https://raw.githubusercontent.com/adriadam10/gameflix/main/platforms.txt"

# --- Shared Functions ---
log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"; }
error() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" >&2; }

download_file() {
    local url="$1"
    local output="$2"
    local extra_args="$3"
    log "Downloading: $url"
    # shellcheck disable=SC2086
    if ! wget -q -c $extra_args -O "$output" "$url"; then
        error "Failed to download $url"
        return 1
    fi
    return 0
}
