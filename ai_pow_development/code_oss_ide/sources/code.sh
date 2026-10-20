#!/bin/bash
set -euo pipefail

# Use the same profile and extension directory for the GUI, CLI and terminal.
# This image runs as root under rootless Docker, so Electron needs --no-sandbox.
exec /usr/bin/code --no-sandbox --password-store=basic \
    --user-data-dir "${CODE_OSS_USER_DATA_DIR:-/root/.config/Code - OSS}" \
    --extensions-dir "${CODE_OSS_EXTENSIONS_DIR:-/opt/code-oss/extensions}" "$@"
