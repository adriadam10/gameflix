#!/bin/bash
# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

log "Configuring services..."

# Hosts
if ! grep -q "$HOSTS_ENTRY" /etc/hosts; then
    log "Updating /etc/hosts..."
    echo "$HOSTS_ENTRY" >> /etc/hosts
fi

# Nginx
if [[ ! -d "$NGINX_DIR" ]]; then
    log "Setting up Nginx cache..."
    tmp_zip="/tmp/nginx.zip"
    if download_file "https://github.com/adriadam10/gameflix/raw/main/batocera/share/system/nginx.zip" "$tmp_zip"; then
        unzip -q -o "$tmp_zip" -d "$SYSTEM_DIR" && rm -f "$tmp_zip"
        download_file "https://github.com/adriadam10/gameflix/raw/main/batocera/share/system/nginx.conf" "${NGINX_DIR}/conf/nginx.conf"
        mkdir -p "${NGINX_DIR}/logs" "${USERDATA}/cache/nginx"
        touch "${NGINX_DIR}/logs/error.log" "${NGINX_DIR}/logs/access.log"
    fi
fi

# Start Nginx
if [[ -x "${NGINX_DIR}/sbin/nginx" ]]; then
    log "Starting Nginx..."
    "${NGINX_DIR}/sbin/nginx" -p "$NGINX_DIR" 2>/dev/null || log "Nginx already running"
fi

# Systems config
SYSTEMS_CFG="/usr/share/emulationstation/es_systems.cfg"
if [[ -f "$SYSTEMS_CFG" ]]; then
    [[ ! -f "${SYSTEMS_CFG}.bak" ]] && cp "$SYSTEMS_CFG" "${SYSTEMS_CFG}.bak"
    rm -f "$SYSTEMS_CFG"
    download_file "https://github.com/adriadam10/gameflix/raw/main/batocera/share/system/es_systems.cfg" "$SYSTEMS_CFG"
fi

log "Services setup complete."
