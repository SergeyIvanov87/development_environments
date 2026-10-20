#!/bin/bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 || ! -d "$1" ]]; then
    echo "Usage: $0 <workspace directory> [container name suffix]" >&2
    exit 1
fi
workspace_path=$(realpath -- "$1")
container_suffix=${2:-$(basename -- "$workspace_path")}
if [[ ! "$container_suffix" =~ ^[a-zA-Z0-9][a-zA-Z0-9_.-]*$ ]]; then
    echo "Container suffix must use letters, digits, underscores, dots or hyphens." >&2
    exit 1
fi
: "${DISPLAY:?Run from an X11/XWayland desktop with DISPLAY set}"
command -v xauth >/dev/null || { echo "Install xauth on the host first." >&2; exit 1; }

# Forward only the current display's authorization cookie. Avoid a global xhost grant.
xauth_file=$(mktemp)
trap 'rm -f -- "$xauth_file"' EXIT
xauth nlist "$DISPLAY" | sed 's/^..../ffff/' | xauth -f "$xauth_file" nmerge -
if [[ ! -s "$xauth_file" ]]; then
    echo "No Xauthority cookie found for DISPLAY=$DISPLAY." >&2
    exit 1
fi

container_name="code_oss_ide_env_${container_suffix}"
# Copy the cookie to tmpfs after startup; the host temporary file is then removed.
# All AI credentials are supplied at runtime or entered in the extensions' login UI.
container_id=$(docker run -d --init --shm-size=256m \
    -e DISPLAY -e XAUTHORITY=/tmp/code-oss.Xauthority \
    -e OPENAI_API_KEY -e ANTHROPIC_API_KEY -e CLAUDE_CODE_OAUTH_TOKEN \
    --add-host=host.docker.internal:host-gateway \
    --mount type=bind,src=/tmp/.X11-unix,dst=/tmp/.X11-unix,readonly \
    --mount "type=bind,src=${workspace_path},dst=/data" \
    --mount type=volume,src=code_oss_ide_env.sshkeys.volume,dst=/sshkeys \
    --mount "type=volume,src=code_oss_ide_env.settings.volume,dst=/root/.config/Code - OSS" \
    --mount type=volume,src=code_oss_ide_env.continue.volume,dst=/root/.continue \
    --mount type=volume,src=code_oss_ide_env.codex.volume,dst=/root/.codex \
    --mount type=volume,src=code_oss_ide_env.claude.volume,dst=/root/.claude \
    --tmpfs /tmp:rw,nosuid,nodev \
    --name "$container_name" \
    --entrypoint /bin/bash \
    "${CODE_OSS_IMAGE:-is140608/code_oss_ide_env:latest}" \
    -c 'while [[ ! -s "$XAUTHORITY" ]]; do sleep 0.1; done; exec /opt/code-oss/init.sh /data')
if ! docker cp "$xauth_file" "${container_id}:/tmp/code-oss.Xauthority"; then
    docker rm -f "$container_id" >/dev/null
    exit 1
fi
docker logs "$container_id"
echo "Started $container_name"
