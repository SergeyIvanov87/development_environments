#!/bin/bash

WORKSPACE_PATH="${1}"
xhost +local:

#docker run -it -e "DISPLAY=$DISPLAY" --mount type=bind,src=/tmp/.X11-unix,dst=/tmp/.X11-unix --device=/dev/dri:/dev/dri --mount type=bind,src=./system_development/sources/patches,dst=/patches --name simple_dev_cont sys_devel_env:latest
docker run -it -e \
	"DISPLAY=$DISPLAY" --mount type=bind,src=/tmp/.X11-unix,dst=/tmp/.X11-unix --device=/dev/dri:/dev/dri \
	-v /run/user/1000/pulse/native:/tmp/pulse-socket -e PULSE_SERVER=unix:/tmp/pulse-socket --device=/dev/snd  \
	--mount type=bind,src=${WORKSPACE_PATH},dst=/data \
	-v sys_devel_env.sshkeys.volume:/sshkeys \
	-v sys_devel_env.browser.data.volume:/root/.config/mozilla/firefox \
	--name sys_devel_env_cont \
	is140608/sys_devel_env:0.0.2

#development_environment:latest
