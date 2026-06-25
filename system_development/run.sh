#!/bin/bash

xhost +local:

#docker run -it -e "DISPLAY=$DISPLAY" --mount type=bind,src=/tmp/.X11-unix,dst=/tmp/.X11-unix --device=/dev/dri:/dev/dri --mount type=bind,src=./system_development/sources/patches,dst=/patches --name simple_dev_cont sys_devel_env:latest
docker run -it -e "DISPLAY=$DISPLAY" --mount type=bind,src=/tmp/.X11-unix,dst=/tmp/.X11-unix --device=/dev/dri:/dev/dri --name sys_devel_env_cont sys_devel_env:latest

#development_environment:latest
