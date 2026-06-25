# to build devel-only

docker buildx build -f system_development/Dockerfile -t is140608/sys_devel_env:latest --annotation "runcmd=docker run -it -e \"DISPLAY=$DISPLAY\" --mount type=bind,src=/tmp/.X11-unix,dst=/tmp/.X11-unix --device=/dev/dri:/dev/dri --name sys_devel_env_cont is140608/sys_devel_env:latest" .

# to build ai_devel

docker buildx build -f ai_devel/Dockerfile --tag ai_devel:latest .
