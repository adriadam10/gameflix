# Platforms Management: Gameflix (Fork)

## Adding a New Platform

1. **Identify Source**: Find a stable remote source (e.g., Myrient).
2. **Update `platforms.txt`**: Add a new line with the following format:
    `PlatformID;RemoteName:RemotePath;IconURL;DisplayName`
    - `PlatformID`: Slug for the platform (e.g., `ps3`).
    - `RemoteName`: Name defined in `rclone.conf`.
    - `IconURL`: Link to a PNG icon.
    - `DisplayName`: Descriptive name for the UI.
3. **Special Handling**:
    - If the platform requires decryption (like PS3), update `batocera.sh` or `webflix.sh` with the necessary logic.
    - If the platform uses large files (ISOs), ensure the Nginx cache and `ratarmount` are correctly configured.

## Modifying Existing Platforms

- **Changing Origins**: Update the remote path in `platforms.txt`. If the remote service changes, also update `rclone.conf`.
- **Filtering**: To hide certain files (like demos), use the filtering logic in the generation scripts (`generate.sh`).

## Supported Platform Examples

- `psx`: Playstation 1
- `psp`: Playstation Portable
- `gc`: GameCube
- `ps3`: Playstation 3 (Special handling with `ps3dec`)
- `n64`: Nintendo 64
- `dreamcast`: Sega Dreamcast
