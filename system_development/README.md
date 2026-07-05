docker buildx build -f devel/Dockerfile --tag devel:latest 

# Create SSH keys volume

LOCAL_HOST_SSHKEYS_MOUNT_POINT=<Absolute path to a local host mount point> && mkdir -p ${LOCAL_HOST_SSHKEYS_MOUNT_POINT} && chmod 777 ${LOCAL_HOST_SSHKEYS_MOUNT_POINT} && docker volume create -d local -o type=none -o device=${LOCAL_HOST_SSHKEYS_MOUNT_POINT} -o o=bind sys_devel_env.sshkeys.volume


# To keep browser data persistent 

LOCAL_HOST_BROWSER_MOUNT_POINT=<Absolute path to a local host mount point> && mkdir -p ${LOCAL_HOST_BROWSER_MOUNT_POINT} && chmod 777 ${LOCAL_HOST_BROWSER_MOUNT_POINT} && docker volume create -d local -o type=none -o device=${LOCAL_HOST_BROWSER_MOUNT_POINT} -o o=bind sys_devel_env.browser.data.volume
