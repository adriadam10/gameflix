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

is_mountpoint() {
    local dir="$1"
    # Check if directory exists
    [[ ! -d "$dir" ]] && return 1
    
    # Use mountpoint command if available (most reliable)
    if command -v mountpoint >/dev/null 2>&1; then
        mountpoint -q "$dir"
        return $?
    fi
    
    # Fallback 1: Check /proc/mounts (Linux standard)
    if grep -q " $(readlink -f "$dir") " /proc/mounts 2>/dev/null; then
        return 0
    fi
    
    # Fallback 2: Check standard mount command output
    # This is less reliable due to formatting but works on some minimal systems
    if mount | grep -q " on $(readlink -f "$dir") "; then
        return 0
    fi
    
    return 1
}
