# Gameflix

![obrázok](https://github.com/user-attachments/assets/c90a7c26-1828-481c-a236-f56d0b19f936)

This project allows running retro games directly from public online sources (like Myrient and The Eye) on Linux machines, specifically optimized for Batocera and Recalbox.

This repository is a fork with significant improvements in performance, platform support, and usability.

## 🚀 Key Improvements in this Fork

### 🎮 PS3 Support

Added experimental support for PS3 games:

- **Decryption**: Integrated `ps3dec` to handle encrypted ISOs automatically.
- **Mounting**: System to mount PS3 ISOs into local folders for easy emulator access.

### ⚡ Optimization and Performance

- **Nginx Cache**: Implemented a proxy cache using Nginx to speed up ROM downloads (especially ZIP files) and reduce latency.
- **Rclone Cache**: Fine-tuned rclone mount parameters for faster remote file access.

### 🛠️ Platform and Origin Updates

- **Updated Sources**: Switched to more stable origins for platforms like PSP, GameCube, and PSX.
- **Clean UI**: Hidden demos and betas from the game list for a better user experience.

### 📂 Better Gamelist Management

- **Automatic Generation**: Improved logic for creating `gamelist.xml` with correct paths and metadata.
- **Thumbnail Handling**: Optimized download and display of libretro thumbnails.

### 📋 Enhanced Debugging

- **Detailed Execution Logs**: Added logging for startup scripts in Batocera and Recalbox to simplify troubleshooting.

---

## 🔧 Installation and Usage

### Requirements

- `rclone` binary (version 1.60+) configured with provided sources.
- `ratarmount` or `fuse-zip` for handling compressed libraries.

### Quick Start (Web Version)

Run the following script to mount the library with cache support:

```bash
bash webflix.sh
```

### Batocera / Recalbox Usage

Copy the `custom.sh` from the respective folders (`batocera/` or `recalbox/`) to your shared drive system folder.
In Batocera, ensure you use the provided `nginx.conf` for cache optimizations.

## 🤝 Credits

Based on the original project by [WizzardSK](https://github.com/WizzardSK/gameflix).
Enhancements and maintenance of this fork by [adriadam10](https://github.com/adriadam10).
