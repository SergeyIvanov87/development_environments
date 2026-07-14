#!/bin/bash

WORKSPACE_PATH="${1}"
xhost +local:

docker run -it -e \
    "DISPLAY=$DISPLAY" --mount type=bind,src=/tmp/.X11-unix,dst=/tmp/.X11-unix --device=/dev/dri:/dev/dri \
    -v /run/user/1000/pulse/native:/tmp/pulse-socket -e PULSE_SERVER=unix:/tmp/pulse-socket --device=/dev/snd  \
    --mount type=bind,src=${WORKSPACE_PATH},dst=/data \
    -v sys_devel_env.sshkeys.volume:/sshkeys \
    -v cursor_ide_env.browser.data.volume:/root/.config/mozilla/firefox \
    -v cursor_ide_env.cursor.data.volume:/root/.cursor \
    --name cursor_ide_env_cont \
    is140608/cursor_ide_env:0.0.2

# TODO with a current user UID/GID
#   --volume /etc/passwd:/etc/passwd:ro --volume /etc/group:/etc/group:ro --user $(id -u):$(id -g) \
