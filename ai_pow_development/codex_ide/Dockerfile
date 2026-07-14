FROM archlinux@sha256:ff410a88e200b133e577f5730b7bfa324e26a333075ee056bf45e911c6ac5671 AS build

ENV WORKDIR=/

WORKDIR $WORKDIR

RUN <<EOF
pacman -Syu --noconfirm git base-devel fakeroot sudo
useradd builduser -m
passwd -d builduser
printf 'builduser ALL=(ALL) ALL\n' | tee -a /etc/sudoers
sudo -u builduser bash -c 'cd ~ && git clone https://aur.archlinux.org/yay.git yay-pkgbuild && cd yay-pkgbuild && makepkg -s --noconfirm'
sudo -u builduser bash -c 'cd ~ && git clone https://aur.archlinux.org/codex-desktop-linux.git  codex-desktop-linux-pkgbuild && cd codex-desktop-linux-pkgbuild && makepkg -s --noconfirm'
EOF

FROM is140608/sys_devel_env:0.0.5 AS base

ENV WORKDIR=/

RUN mkdir /packages
COPY --from=build /home/builduser/yay-pkgbuild/*pkg.tar.zst  /packages/
COPY --from=build /home/builduser/codex-desktop-linux-pkgbuild/*pkg.tar.zst  /packages/
COPY ai_pow_development/codex_ide/sources/*.sh /

RUN <<EOF
pacman -Syu --noconfirm openai-codex dbus
pacman -U --noconfirm  /packages/*.pkg.tar.zst
rm -r /packages/*.pkg.tar.zst
pacman -Scc --noconfirm
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
VOLUME ["/data", "/sshkeys", "/root/.config/mozilla/firefox", "/root/.codex"]
ENTRYPOINT ["/init.sh", "/", "/data" ]
