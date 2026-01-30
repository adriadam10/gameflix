---
description: detailed rules about testing and verification in this project
---

# Testing Strategy

- **No Local Runtime Testing**: The codebase is designed to run on a Batocera system (Linux-based gaming OS). The local development environment does not replicate this environment (e.g., missing specific paths, binaries like `batocera-save-overlay`, or network configurations).
- **User-Side Verification**: Do NOT attempt to run scripts locally to verify functionality unless they are pure logic/unit tests that mock all system dependencies. Always assume the user will copy scripts to the Batocera device for testing.
- **Batocera Environment Reference**: Scripts rely on paths like `/userdata`, `/usr/share/emulationstation`, and specific network aliases (`local.myrient.erista.me`). These are not present locally.
