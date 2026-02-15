#!/bin/bash
# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

log "Configuring services..."

# WebCache Config
if [[ ! -f "$WEBCACHE_CONF" ]]; then
    log "Downloading WebCache configuration..."
    download_file "https://raw.githubusercontent.com/adriadam10/webcache/master/config.toml" "$WEBCACHE_CONF"
    # Adjust cache directory for Batocera
    sed -i "s|cache_dir = \"/var/cache/webcache\"|cache_dir = \"${CACHE_DIR}/webcache\"|g" "$WEBCACHE_CONF"
    # Set cache size to 250GB (268435456000 bytes)
    sed -i "s|max_size_bytes = 10737418240|max_size_bytes = 268435456000|g" "$WEBCACHE_CONF"
fi

# Systems config
SYSTEMS_CFG="/usr/share/emulationstation/es_systems.cfg"
if [[ -f "$SYSTEMS_CFG" ]]; then
    [[ ! -f "${SYSTEMS_CFG}.bak" ]] && cp "$SYSTEMS_CFG" "${SYSTEMS_CFG}.bak"
    rm -f "$SYSTEMS_CFG"
    download_file "https://github.com/adriadam10/gameflix/raw/main/batocera/share/system/es_systems.cfg" "$SYSTEMS_CFG"
fi

log "Services setup complete."
