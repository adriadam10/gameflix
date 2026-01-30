# Coding Conventions: Gameflix (Fork)

## Bash Scripting

- **Logging**: All major operations should be logged. Use `echo` for progress and errors. In Batocera/Recalbox scripts, redirect output to a log file (e.g., `/tmp/gameflix.log`).
- **Paths**: Use absolute paths or define variables like `ROM_DIR`, `SHARE_DIR` at the beginning of the script.
- **Error Handling**: Check if commands like `rclone mount` or `wget` succeed before proceeding.
- **Variables**: Use double quotes for all variable expansions to handle spaces in file names (crucial for ROM filenames).

## Nginx Caching

- **Configuration**: Always use the configuration file located in `batocera/share/system/nginx.conf`.
- **Cache Paths**: Ensure the cache directory exists before starting Nginx. Default is usually `~/share/system/.cache/nginx`.

## UI/UX

- **Thumbnails**: Thumbnails should be sourced from `thumbnails.libretro.com` whenever possible.
- **Gamelist**: The `gamelist.xml` should follow the EmulationStation format. Ensure tags like `<path>`, `<name>`, and `<image>` are properly populated.
- **Visibility**: Be proactive in hiding non-game content (demos, betas) from the UI via the generation scripts.

## Remote Sources

- **Update rclone.conf**: When adding a new source, update `rclone.conf` and ensure the remote name matches what is used in `platforms.txt`.
- **Myrient Preferred**: For most platforms, Myrient is the preferred source due to stability and archive format.
