# Create SSH keys volume

LOCAL_HOST_SSHKEYS_MOUNT_POINT=<Absolute path to a local host mount point> && mkdir -p ${LOCAL_HOST_SSHKEYS_MOUNT_POINT} && chmod 777 ${LOCAL_HOST_SSHKEYS_MOUNT_POINT} && docker volume create -d local -o type=none -o device=${LOCAL_HOST_SSHKEYS_MOUNT_POINT} -o o=bind sys_devel_env.sshkeys.volume


# To keep browser data persistent

LOCAL_HOST_BROWSER_MOUNT_POINT=<Absolute path to a local host mount point> && mkdir -p ${LOCAL_HOST_BROWSER_MOUNT_POINT} && chmod 777 ${LOCAL_HOST_BROWSER_MOUNT_POINT} && docker volume create -d local -o type=none -o device=${LOCAL_HOST_BROWSER_MOUNT_POINT} -o o=bind sys_devel_env.browser.data.volume

# To build

docker build -t is140608/sys_devel_env:<version> -t is140608/sys_devel_env:latest .
docker buildx build -f system_development/Dockerfile -t is140608/sys_devel_env:<version> -t is140608/sys_devel_env:latest --push --annotation "runcmd=docker run -it -e \
        \"DISPLAY=$DISPLAY\" --mount type=bind,src=/tmp/.X11-unix,dst=/tmp/.X11-unix --device=/dev/dri:/dev/dri \
        -v /run/user/1000/pulse/native:/tmp/pulse-socket -e PULSE_SERVER=unix:/tmp/pulse-socket --device=/dev/snd  \
        --mount type=bind,src=${WORKSPACE_PATH},dst=/data \
        -v sys_devel_env.sshkeys.volume:/sshkeys \
        -v sys_devel_env.browser.data.volume:/root/.config/mozilla/firefox \
        --name sys_devel_env_cont \
        is140608/sys_devel_env:latest" .
