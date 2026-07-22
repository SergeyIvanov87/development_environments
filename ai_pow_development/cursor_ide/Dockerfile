FROM archlinux@sha256:ff410a88e200b133e577f5730b7bfa324e26a333075ee056bf45e911c6ac5671 AS build

ENV WORKDIR=/

WORKDIR $WORKDIR

RUN <<EOF
pacman -Syu --noconfirm git base-devel sudo fakeroot

useradd builduser -m # Create the builduser
passwd -d builduser # Delete the buildusers password
printf 'builduser ALL=(ALL) ALL\n' | tee -a /etc/sudoers
sudo -u builduser bash -c 'cd ~ && git clone https://aur.archlinux.org/yay.git yay-pkgbuild && cd yay-pkgbuild && makepkg -s --noconfirm'
sudo -u builduser bash -c 'cd ~ && git clone https://aur.archlinux.org/cursor-bin.git  cursor-pkgbuild && cd cursor-pkgbuild && makepkg -s --noconfirm'
pacman -Scc --noconfirm
EOF

FROM is140608/sys_devel_env:latest AS base

ENV WORKDIR=/

RUN mkdir -p /packages
COPY --from=build /home/builduser/yay-pkgbuild/*pkg.tar.zst  /packages/
COPY --from=build /home/builduser/cursor-pkgbuild/*pkg.tar.zst  /packages/
COPY ai_pow_development/cursor_ide/sources/*.sh /
COPY ai_pow_development/cursor_ide/sources/cursor_extension_list /

RUN <<EOF
pacman -Syu --noconfirm dbus net-tools
pacman -U --noconfirm  /packages/*.pkg.tar.zst
rm -r /packages/*.pkg.tar.zst
rm -rf /var/lib/pacman/sync/* /root/.cache/* /tmp/*
EOF

# In rootless docker mode the default `root` is the user of a host machine who launches the docker image
# There is no need to create an additional user as it contributes nothing into the isolation here.
# Moreover the user inside the container should have full access to mounted volumes related to the host machine
# For root/mapped docker the behavior may be different
#RUN <<EOF
#useradd -m -G sys,log,network,rfkill,systemd-journal,video,storage,audio,wheel,adm -s /bin/bash user
#printf 'user ALL=(ALL) NOPASSWD: ALL\n' | tee -a /etc/sudoers
#####Temporary
#cp -r /sshkeys ${WORKDIR}/sshkeys
#chown user:user ${WORKDIR}/sshkeys
#cp /*.sh ${WORKDIR}
#chown user:user ${WORKDIR}/*.sh
#chmod +x ${WORKDIR}/*.sh
#mkdir -p ${WORKDIR}/.config/mozilla/firefox
#cp -r /root/.config/geany ${WORKDIR}/.config/
#chown -R user:user ${WORKDIR}/.config
#EOF


WORKDIR $WORKDIR
EXPOSE 1455
VOLUME ["/data", "/sshkeys", "/root/.config/mozilla/firefox", "/root/.cursor"]

ARG GIT_COMMIT=unknown
ARG CREATED_TS=unknown
LABEL org.opencontainers.image.title="AI powered by Cursor System-level development utilities(C++,Python)" \
      org.opencontainers.image.source=https://github.com/SergeyIvanov87/development_environments.git \
      org.opencontainers.image.description="Contains C++/Python standard libraries, Cursor IDE, lightweight IDE 'Geany', bare-minimum multimedia as Firefox-browser" \
      org.opencontainers.image.created=${CREATED_TS} \
      org.opencontainers.image.version=unknown \
      org.opencontainers.image.revision=${GIT_COMMIT} \
      org.opencontainers.image.documentation=https://github.com/SergeyIvanov87/development_environments/blob/main/ai_pow_development/cursor_ide/README.md

ENTRYPOINT ["/init.sh", "/", "/data" ]
