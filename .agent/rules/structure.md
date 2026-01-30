# Project Structure: Gameflix (Fork)

This project is a system for running retro games directly from public online sources on Linux machines, specifically optimized for Batocera and Recalbox.

## Core Directories and Files

- `/` (Root):
  - `batocera.sh`: Orchestrator script for Batocera setup (downloads and runs modular components).
  - `webflix.sh`: Main script for web-based library mounting and setup.
  - `generate.sh` / `gen.sh`: Scripts for generating the game collection and `gamelist.xml`.
  - `mount.sh`: script for mounting the remote libraries.
  - `rclone.conf`: Rclone configuration for various remote sources (Myrient, The Eye, etc.).
  - `platforms.txt`: Database of supported platforms, their remote paths, and icons.
  - `script.js`: Logic for the web-based game selection interface.
- `batocera/`: Specific configurations and scripts for Batocera.
  - `scripts/`: Modular setup components (invoked by `batocera.sh`):
    - `common.sh`: Shared variables, paths, and helper functions (`log`, `download_file`).
    - `tools.sh`: Parallel installation of binaries and decryption tools.
    - `services.sh`: System configuration (`/etc/hosts`, Nginx setup).
    - `mount.sh`: Rclone mount orchestration.
    - `platforms.sh`: Concurrent platform processing and `gamelist.xml` generation.
  - `share/system/custom.sh`: Boot script for Batocera (triggers the orchestrator).
  - `share/system/nginx.conf`: Nginx configuration for caching ROM downloads.
- `recalbox/`: Specific configurations for Recalbox (legacy).
- `roms/` (Dynamic): Local mount point for remote ROMs.

## Architecture

1. **Remote Storage**: ROMs are hosted on public services like Myrient.
2. **Mounting**: `rclone` and `ratarmount` / `fuse-zip` are used to mount these remote directories as local folders.
3. **Caching**: In this fork, Nginx is used as a proxy cache to speed up repeated accesses to ZIP files.
4. **Modular Orchestration**: The setup process is broken into focused, parallelizable components fetched at runtime by `batocera.sh`.
5. **Interface**: A static HTML/JS interface allows users to browse games.
6. **Batocera Integration**: The `custom.sh` script automates the mounting and Nginx startup on boot by executing the remote orchestrator.

## Important Note for AI Agents

When modifying scripts, be aware that many paths are hardcoded to `~/` or `/userdata/` (in Batocera). Always check the execution context (standard Linux vs Batocera).
