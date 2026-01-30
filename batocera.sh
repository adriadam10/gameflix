#!/bin/bash

# ==============================================================================
# Gameflix Batocera Orchestrator
# Executes modular setup components in parallel
# ==============================================================================

BASE_URL="https://raw.githubusercontent.com/adriadam10/gameflix/main"
SCRIPTS_DIR="/tmp/gameflix_scripts"
mkdir -p "$SCRIPTS_DIR"

log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] ORCHESTRATOR: $1"; }

download_script() {
    local name="$1"
    wget -q -O "${SCRIPTS_DIR}/${name}" "${BASE_URL}/batocera/scripts/${name}"
    chmod +x "${SCRIPTS_DIR}/${name}"
}

log "Fetching modular components..."
for script in common.sh tools.sh services.sh mount.sh platforms.sh test_nginx.sh; do
    download_script "$script" &
done
wait

# Initial System Prep
if command -v emulationstation &> /dev/null; then
    emulationstation stop 2>/dev/null
fi
chvt 3 && clear
mount -o remount,size=30000M /tmp 2>/dev/null

log "Starting parallel setup stages..."

# Stage 1: Parallel Tools and Services
"${SCRIPTS_DIR}/tools.sh" &
T_PID=$!
"${SCRIPTS_DIR}/services.sh" &
S_PID=$!

wait $T_PID $S_PID
log "Stage 1 (Tools & Services) complete."

# Stage 1.5: Verify Nginx (Requires services.sh)
log "Verifying Nginx configuration..."
"${SCRIPTS_DIR}/test_nginx.sh" || log "WARNING: Nginx verification failed, but continuing..."

# Stage 2: Mounting (Requires rclone from tools.sh)
"${SCRIPTS_DIR}/mount.sh"
log "Stage 2 (Mounting) complete."

# Stage 3: Platforms (Requires mount.sh)
"${SCRIPTS_DIR}/platforms.sh"
log "Stage 3 (Platforms) complete."

log "Finalizing..."
chvt 2
curl -s "http://127.0.0.1:1234/reloadgames" &> /dev/null

log "=============================================================================="
log " Gameflix setup finished successfully!"
log "=============================================================================="
