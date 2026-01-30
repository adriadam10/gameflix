# 🎮 Gameflix on Batocera

This guide explains how the optimized Gameflix script architecture works within the **Batocera** environment.

## 🏗️ Architecture Overview

To improve performance and maintainability, the Batocera setup is split into a modular, parallelized system.

### 1. The Orchestrator (`batocera.sh`)

The main [batocera.sh](file:///home/adriadam10/gameflix/batocera.sh) script acts as the master orchestrator. When executed, it perform the following:

- Creates a temporary directory in `/tmp` for operational scripts.
- **Asynchronously** fetches modular components from the repository.
- Manages the execution flow to ensure dependencies are met while maximizing parallelism.

### 2. Modular Components

The setup logic is distributed across focused scripts in `batocera/scripts/`:

- **`common.sh`**: Shared environment variables (paths, URLs) and utility functions.
- **`tools.sh`**: Concurrent installation of required binaries (`rclone`, `httpdirfs`, `ratarmount`, `ps3dec`).
- **`services.sh`**: Configuration of system level services, including `/etc/hosts` patches and the **Nginx Proxy Cache** setup.
- **`mount.sh`**: Orchestration of the remote library mount via `rclone`.
- **`platforms.sh`**: High-parallelism processing of game platforms, including bind-mounting and `gamelist.xml` generation.

## 🚀 How it Works (Boot Flow)

1. **Integration**: The standard Batocera boot script [custom.sh](file:///home/adriadam10/gameflix/batocera/share/system/custom.sh) is configured to call the orchestrator:

   ```bash
   curl -s -L https://raw.githubusercontent.com/adriadam10/gameflix/main/batocera.sh | bash
   ```

2. **Initialization**: The orchestrator stops EmulationStation to prevent database locks and resizes `/tmp` to accommodate assets.
3. **Stage 1 (Parallel)**: Tools are installed and Services (Nginx) are configured simultaneously.
4. **Stage 2 (Sequential)**: The remote library is mounted once tools are ready.
5. **Stage 3 (Parallel)**: Platforms are processed concurrently. The number of parallel tasks is **automatically optimized** based on your device's CPU cores (`nproc`).
6. **Finalization**: EmulationStation is refreshed using its internal API to reflect the new games without a full reboot.

## ⚡ Key Optimizations in this Fork

- **Throttled Parallelism**: Scales with your hardware (CPU cores) to avoid crashes on low-powered devices (like Orange Pi or older NUCs).
- **Nginx Cache**: Reduces latency for ZIP-based ROMs by caching frequently accessed headers and data blocks.
- **Idempotency**: All scripts check if a task is already completed (e.g., if a mount exists or a binary is installed) before running, making re-runs extremely fast.

## 📝 Troubleshooting

Logs for the setup process are captured in real-time at:
`/userdata/system/gameflix_setup.log`

You can monitor the setup via SSH with:

```bash
tail -f /userdata/system/gameflix_setup.log
```
