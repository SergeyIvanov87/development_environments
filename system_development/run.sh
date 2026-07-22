#!/bin/bash

WORKSPACE_PATH="${1}"
CONTAINER_NAME_SUFFIX="${2}"

if [ -z ${WORKSPACE_PATH} ]; then
    echo "ERROR: WORKSPACE_PATH is empty. Usage ./run.sh <workspace path> <desired suffix to a name of the container to run>"
fi


if [ -z ${CONTAINER_NAME_SUFFIX} ]; then
    CONTAINER_NAME_SUFFIX=$(basename "${WORKSPACE_PATH}")
fi

xhost +local:

docker run -d -e \
    "DISPLAY=$DISPLAY" --mount type=bind,src=/tmp/.X11-unix,dst=/tmp/.X11-unix --device=/dev/dri:/dev/dri \
    -v /run/user/1000/pulse/native:/tmp/pulse-socket -e PULSE_SERVER=unix:/tmp/pulse-socket --device=/dev/snd  \
    --mount type=bind,src=${WORKSPACE_PATH},dst=/data \
    -v sys_devel_env.sshkeys.volume:/sshkeys \
    -v sys_devel_env.browser.data.volume:/root/.config/mozilla/firefox \
    --name sys_devel_env_cont_${CONTAINER_NAME_SUFFIX} \
    is140608/sys_devel_env:latest
