#!/bin/bash
# shellcheck disable=SC2088,SC2001
# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

log "Processing platforms..."

PLATFORMS_FILE="/tmp/platforms.txt"
download_file "$PLATFORMS_URL" "$PLATFORMS_FILE" || exit 1

# Make parallel jobs relative to CPU cores (min 2, default to nproc)
CPU_CORES=$(nproc 2>/dev/null || echo 4)
MAX_PARALLEL=$(( CPU_CORES > 2 ? CPU_CORES : 2 ))
CURRENT_JOBS=0
declare -A processed_thumbs

process_platform() {
    local line="$1"
    local platform remote_path thumb_repo display_name clean_display_name platform_dir rom_subdir
    IFS=";" read -ra fields <<< "$line"
    platform="${fields[0]}"
    remote_path="${fields[1]}"
    thumb_repo="${fields[2]}"
    display_name="${fields[3]}"
    
    clean_display_name=$(echo "$display_name" | sed 's/<[^>]*>//g')
    platform_dir="${ROMS_BASE_DIR}/${platform}"
    rom_subdir="${platform_dir}/${clean_display_name}"
    
    mkdir -p "$rom_subdir"
    
    # Thumbs
    if [[ ! -f "${THUMB_DIR}/${platform}.png" ]]; then
        download_file "https://raw.githubusercontent.com/fabricecaruso/es-theme-carbon/master/art/consoles/${platform}.png" "${THUMB_DIR}/${platform}.png"
    fi
    
    if [[ -z "${processed_thumbs[$thumb_repo]}" && ! -d "${THUMBS_BASE_DIR}/${thumb_repo}" ]]; then
        processed_thumbs[$thumb_repo]=1
        local repo_slug="${thumb_repo// /_}"
        local thumb_zip="/tmp/${repo_slug}.zip"
        if download_file "https://github.com/WizzardSK/${repo_slug}/archive/refs/heads/master.zip" "$thumb_zip"; then
            mkdir -p "${THUMBS_BASE_DIR}/${thumb_repo}"
            unzip -qq -o "$thumb_zip" -d "${THUMBS_BASE_DIR}/${thumb_repo}"
            rm "$thumb_zip"
            mv "${THUMBS_BASE_DIR}/${thumb_repo}/${repo_slug}-master/"* "${THUMBS_BASE_DIR}/${thumb_repo}/" 2>/dev/null
        fi
    fi

    # Bind Mount
    if ! is_mountpoint "$rom_subdir"; then
        if [[ ! "$remote_path" =~ \.zip$ ]]; then
            mount -o bind "${ROM_DIR}/${remote_path}" "$rom_subdir" 2>/dev/null
        fi
    fi

    # Gamelist
    local gamelist_xml="${platform_dir}/gamelist.xml"
    if [[ ! -f "$gamelist_xml" ]]; then
        {
            echo '<?xml version="1.0"?>'
            echo '<gameList>'
            for game_path in "$rom_subdir"/*; do
                [[ -e "$game_path" ]] || continue
                local filename basename img titleshot thumb_img marquee hidden
                filename=$(basename "$game_path")
                basename="${filename%.*}"
                img="~/../thumbs/${thumb_repo}/Named_Snaps/${basename}.png"
                titleshot="~/../thumbs/${thumb_repo}/Named_Titles/${basename}.png"
                thumb_img="~/../thumbs/${thumb_repo}/Named_Boxarts/${basename}.png"
                marquee="~/../thumbs/${thumb_repo}/Named_Logos/${basename}.png"
                hidden=""
                if ! (echo "$filename" | grep -iE 'pal|europe|(eu)' | grep -ivqE 'beta|demo'); then
                    hidden="<hidden>true</hidden>"
                fi
                cat <<EOF
    <game>
        <path>./${clean_display_name}/${filename}</path>
        <name>${basename}</name>
        <image>${img}</image>
        <titleshot>${titleshot}</titleshot>
        <thumbnail>${thumb_img}</thumbnail>
        <marquee>${marquee}</marquee>
        ${hidden}
    </game>
EOF
            done
            cat <<EOF
    <folder>
        <path>./${clean_display_name}</path>
        <name>${clean_display_name}</name>
        <image>~/../thumb/${platform}.png</image>
    </folder>
</gameList>
EOF
        } > "$gamelist_xml"
    fi
}

while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    process_platform "$line" &
    ((CURRENT_JOBS++))
    if ((CURRENT_JOBS >= MAX_PARALLEL)); then
        wait -n
        ((CURRENT_JOBS--))
    fi
done < "$PLATFORMS_FILE"
wait
rm -f "$PLATFORMS_FILE"
log "Platform processing complete."
