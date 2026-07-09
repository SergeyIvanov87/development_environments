FROM archlinux@sha256:ff410a88e200b133e577f5730b7bfa324e26a333075ee056bf45e911c6ac5671 AS base

ENV WORKDIR=/
WORKDIR $WORKDIR

RUN <<EOF
pacman -Syu --noconfirm
pacman -S --noconfirm --needed geany geany-plugins nano mc kitty diffutils gcc gdb python python-pip python-black python-pylint python-pytest patch git tmuxp openssh strace firefox less sudo xdg-utils xdg-desktop-portal
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
ENTRYPOINT ["/init.sh", "/", "/data"]
