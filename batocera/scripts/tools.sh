#!/bin/bash
# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

log "Checking/Installing tools..."

# Symlink for fusermount3
if [[ ! -L /usr/bin/fusermount3 ]] && [[ ! -e /usr/bin/fusermount3 ]]; then
    ln -sf /usr/bin/fusermount /usr/bin/fusermount3
fi

# Rclone
if ! command -v rclone &> /dev/null; then
    log "Installing rclone..."
    curl -s https://rclone.org/install.sh | bash > /dev/null 2>&1
fi

# Binaries from URL
install_bin() {
    local name="$1"
    local url="$2"
    if [[ ! -f "${SYSTEM_DIR}/$name" ]]; then
        download_file "$url" "${SYSTEM_DIR}/$name" && chmod +x "${SYSTEM_DIR}/$name"
    fi
}

(
    install_bin "httpdirfs" "https://github.com/adriadam10/gameflix/raw/main/batocera/share/system/httpdirfs"
    install_bin "mount-zip" "https://github.com/adriadam10/gameflix/raw/main/batocera/share/system/mount-zip"
    install_bin "ratarmount" "https://github.com/mxmlnkn/ratarmount/releases/download/v0.15.2/ratarmount-0.15.2-x86_64.AppImage"
) &

# PS3 Tools
if [[ ! -f "${SYSTEM_DIR}/ps3decremake_cli" ]]; then
    (
        download_file "https://github.com/adriadam10/gameflix/raw/main/batocera/share/system/ps3decremake_cli" "${SYSTEM_DIR}/ps3decremake_cli" && chmod +x "${SYSTEM_DIR}/ps3decremake_cli"
        tmp_keys="/tmp/ps3_keys.zip"
        if download_file "https://github.com/adriadam10/gameflix/raw/main/batocera/share/system/ps3_keys.zip" "$tmp_keys"; then
            unzip -q -o "$tmp_keys" -d "$SYSTEM_DIR" && rm -f "$tmp_keys"
        fi
    ) &
fi

wait
log "Tools setup complete."
