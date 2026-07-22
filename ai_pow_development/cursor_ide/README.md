# Create SSH keys volume

LOCAL_HOST_SSHKEYS_MOUNT_POINT=<Absolute path to a local host mount point> && mkdir -p ${LOCAL_HOST_SSHKEYS_MOUNT_POINT} && chmod 777 ${LOCAL_HOST_SSHKEYS_MOUNT_POINT} && docker volume create -d local -o type=none -o device=${LOCAL_HOST_SSHKEYS_MOUNT_POINT} -o o=bind cursor_ide_env.sshkeys.volume


# To keep browser data persistent

LOCAL_HOST_BROWSER_MOUNT_POINT=<Absolute path to a local host mount point> && mkdir -p ${LOCAL_HOST_BROWSER_MOUNT_POINT} && chmod 777 ${LOCAL_HOST_BROWSER_MOUNT_POINT} && docker volume create -d local -o type=none -o device=${LOCAL_HOST_BROWSER_MOUNT_POINT} -o o=bind cursor_ide_env.browser.data.volume

# To keep codex data persistent

LOCAL_HOST_CODEX_MOUNT_POINT=<Absolute path to a local host mount point> && mkdir -p ${LOCAL_HOST_CODEX_MOUNT_POINT} && chmod 777 ${LOCAL_HOST_CODEX_MOUNT_POINT} && docker volume create -d local -o type=none -o device=${LOCAL_HOST_CODEX_MOUNT_POINT} -o o=bind cursor_ide_env.cursor.data.volume


# To build

docker buildx build -f ai_pow_development/cursor_ide/Dockerfile -t is140608/cursor_ide_env:latest .

# To run

ai_pow_development/cursor_ide/run.sh <your git repo or other workspace> <container name suffix>
