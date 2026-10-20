#!/bin/bash
set -euo pipefail

echo "Preparing configuration..."
/opt/code-oss/configure.sh

if [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
    echo "A display is required. Use run.sh from an X11/XWayland desktop." >&2
    exit 1
fi

# Set up SSH once in the IDE terminal with ssh-keygen, or mount an existing
# /sshkeys/github_sshkey. Do not launch interactive key-generation during boot.
mkdir -p "${HOME}/.ssh"
if [[ -f /sshkeys/github_sshkey && ! -e "${HOME}/.ssh/config" ]]; then
    printf 'Host github.com\n  IdentityFile /sshkeys/github_sshkey\n  IdentitiesOnly yes\n' > "${HOME}/.ssh/config"
    chmod 0600 "${HOME}/.ssh/config"
fi

echo "Starting Code OSS"
# --wait keeps the main process alive for the window and propagates startup errors.
exec dbus-run-session -- code --wait --disable-dev-shm-usage "$@"
