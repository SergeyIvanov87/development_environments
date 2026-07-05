FROM archlinux@sha256:ff410a88e200b133e577f5730b7bfa324e26a333075ee056bf45e911c6ac5671 AS build

ENV WORKDIR=/

WORKDIR $WORKDIR

RUN <<EOF
pacman -Syu --noconfirm git base-devel sudo

useradd builduser -m # Create the builduser
passwd -d builduser # Delete the buildusers password
printf 'builduser ALL=(ALL) ALL\n' | tee -a /etc/sudoers
sudo -u builduser bash -c 'cd ~ && git clone https://aur.archlinux.org/yay.git yay-pkgbuild && cd yay-pkgbuild && makepkg -s --noconfirm'
#sudo -u builduser bash -c 'cd ~ && git clone https://aur.archlinux.org/cursor-bin.git  cursor-pkgbuild && cd cursor-pkgbuild && makepkg -s --noconfirm'
#sudo -u builduser bash -c 'cd ~ && git clone https://aur.archlinux.org/openai-codex-desktop.git  openai-codex-desktop-pkgbuild && cd openai-codex-desktop-pkgbuild && makepkg -s --noconfirm'
sudo -u builduser bash -c 'cd ~ && git clone https://aur.archlinux.org/codex-desktop-linux.git  codex-desktop-linux-pkgbuild && cd codex-desktop-linux-pkgbuild && makepkg -s --noconfirm'
EOF

FROM is140608/sys_devel_env:0.0.3 AS base

ENV WORKDIR=/home/user/

RUN mkdir /packages
COPY --from=build /home/builduser/yay-pkgbuild/*pkg.tar.zst  /packages/
#COPY --from=build /home/builduser/openai-codex-desktop-pkgbuild/*pkg.tar.zst  /packages/
COPY --from=build /home/builduser/codex-desktop-linux-pkgbuild/*pkg.tar.zst  /packages/
COPY ai_pow_development/codex_ide/sources/*.sh /

#Temporary
RUN ls -la /
#COPY /register_ssh_key.sh ${WORKDIR}
#COPY /run_cmd_forever.sh ${WORKDIR}

RUN <<EOF
ls -la /packages/
pacman -U --noconfirm  /packages/*.pkg.tar.zst
pacman -S --noconfirm sudo openai-codex
pacman -Scc
EOF

RUN <<EOF
useradd -m -G sys,log,network,rfkill,systemd-journal,video,storage,audio,wheel,adm -s /bin/bash user
printf 'user ALL=(ALL) ALL\n' | tee -a /etc/sudoers
#####Temporary
cp -r /sshkeys ${WORKDIR}/sshkeys
chown user:user ${WORKDIR}/sshkeys
cp /*.sh ${WORKDIR}
chown user:user ${WORKDIR}/*.sh
mkdir -p ${WORKDIR}/.config/mozilla/firefox
cp -r /root/.config/geany ${WORKDIR}/.config/
chown -R user:user ${WORKDIR}/.config
EOF


WORKDIR $WORKDIR
USER user
EXPOSE 1455
VOLUME ["/home/user/data", "/sshkeys", "$WORKDIR/.config/mozilla/firefox"]
ENTRYPOINT "${WORKDIR}/init.sh" "${WORKDIR}" "/home/user/data"
