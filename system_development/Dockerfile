FROM archlinux@sha256:ff410a88e200b133e577f5730b7bfa324e26a333075ee056bf45e911c6ac5671 AS build

ENV WORKDIR=/

WORKDIR $WORKDIR

RUN <<EOF
pacman -Syu --noconfirm git base-devel fakeroot sudo go
useradd builduser -m
passwd -d builduser
printf 'builduser ALL=(ALL) ALL\n' | tee -a /etc/sudoers
sudo -u builduser bash -c 'cd ~ && git clone https://aur.archlinux.org/yay.git yay-pkgbuild && cd yay-pkgbuild && makepkg -s --noconfirm'
sudo -u builduser bash -c 'cd ~ && git clone https://aur.archlinux.org/act-git.git act-git-pkgbuild && cd act-git-pkgbuild && makepkg -s --noconfirm'
EOF



FROM archlinux@sha256:ff410a88e200b133e577f5730b7bfa324e26a333075ee056bf45e911c6ac5671 AS base

ENV WORKDIR=/
WORKDIR $WORKDIR

RUN mkdir /packages
COPY --from=build /home/builduser/yay-pkgbuild/*pkg.tar.zst  /packages/
COPY --from=build /home/builduser/act-git-pkgbuild/*pkg.tar.zst  /packages/

RUN <<EOF
pacman -Syu --noconfirm
pacman -S --noconfirm --needed geany geany-plugins nano mc kitty diffutils gcc gdb python python-pip python-black python-pylint python-pytest patch git tmuxp openssh strace firefox less sudo xdg-utils xdg-desktop-portal net-tools dbus base-devel fakeroot
pacman -U --noconfirm  /packages/*.pkg.tar.zst
rm -r /packages/*.pkg.tar.zst
pacman -Scc --noconfirm
rm -rf /var/lib/pacman/sync/* /root/.cache/* /tmp/* /var/tmp/*
EOF

COPY system_development/sources/patches /patches

RUN <<EOF
xdg-settings set default-web-browser firefox.desktop
xdg-mime default firefox.desktop x-scheme-handler/http
xdg-mime default firefox.desktop x-scheme-handler/https

mkdir -p /root/.config/geany/
mkdir -p /root/.config/mozilla/firefox
cp /patches/geany/geany.conf /root/.config/geany/
cp /patches/geany/session.conf /root/.config/geany/
cp -r /patches/geany/plugins /root/.config/geany/
patch -R /root/.config/geany/geany.conf /patches/geany/geany.conf.patch
patch -R /root/.config/geany/session.conf /patches/geany/session.conf.patch
EOF

RUN <<EOF
echo -e "export HISTFILESIZE=\nexport HISTSIZE=\nexport HISTTIMEFORMAT='%F %T '" >> /root/.bashrc
EOF

COPY system_development/sources/*.sh ${WORKDIR}/

VOLUME ["/data", "/sshkeys", "/root/.config/mozilla/firefox"]

ARG GIT_COMMIT=unknown
ARG CREATED_TS=unknown
LABEL org.opencontainers.image.title="System-level development utilities(C++,Python)" \
      org.opencontainers.image.source=https://github.com/SergeyIvanov87/development_environments.git \
      org.opencontainers.image.description="Contains C++/Python standard libraries, lightweight IDE 'Geany', bare-minimum multimedia as Firefox-browser" \
      org.opencontainers.image.created=${CREATED_TS} \
      org.opencontainers.image.version=unknown \
      org.opencontainers.image.revision=${GIT_COMMIT} \
      org.opencontainers.image.documentation=https://github.com/SergeyIvanov87/development_environments/blob/main/system_development/README.md

ENTRYPOINT ["/init.sh", "/", "/data"]
