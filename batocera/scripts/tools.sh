#!/bin/bash
# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

log "Checking/Installing tools..."

# Symlink for fusermount3
if [[ ! -L /usr/bin/fusermount3 ]] && [[ ! -e /usr/bin/fusermount3 ]]; then
    ln -sf /usr/bin/fusermount /usr/bin/fusermount3
fi

# WebCache
if [[ ! -f "${SYSTEM_DIR}/webcache" ]]; then
    log "Installing webcache..."
    # Determine arch
    case "$(uname -m)" in
        x86_64) ARCH="x86_64-unknown-linux-gnu" ;;
        aarch64) ARCH="aarch64-unknown-linux-gnu" ;;
        armv7l) ARCH="armv7-unknown-linux-gnueabihf" ;;
        *) log "Unsupported architecture: $(uname -m)"; exit 1 ;;
    esac
    
    WEBCACHE_URL="https://github.com/adriadam10/webcache/releases/latest/download/webcache-${ARCH}.tar.gz"
    tmp_tar="/tmp/webcache.tar.gz"
    
    if download_file "$WEBCACHE_URL" "$tmp_tar"; then
        tar -xzf "$tmp_tar" -C "${SYSTEM_DIR}" webcache
        chmod +x "${SYSTEM_DIR}/webcache"
        rm -f "$tmp_tar"
    fi
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
