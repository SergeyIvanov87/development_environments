FROM archlinux@sha256:ff410a88e200b133e577f5730b7bfa324e26a333075ee056bf45e911c6ac5671

ENV WORKDIR=/

WORKDIR $WORKDIR

RUN <<EOF
pacman -Syu --noconfirm
pacman -S --noconfirm geany geany-plugins nano mc kitty
pacman -S --noconfirm diffutils gcc gdb python python-pip python-black python-pylint python-pytest
pacman -S --noconfirm patch git tmuxp openssh
pacman -S --noconfirm strace
pacman -S --noconfirm chromium
EOF

RUN <<EOF
pacman -Scc
EOF

# TODO Since we pruned packages cache, it would be a good idea to use 2-step build process and create a fresh image with installed packages only
COPY system_development/sources/patches /patches
COPY system_development/sources/*.sh ${WORKDIR}/

# to generate initial config
#RUN <<EOF
#geany & >/dev/null
#PID=$!
#sleep 3
#kill -9 ${PID}
#EOF
RUN << EOF
mkdir -p /root/.config/geany/
cp /patches/geany/geany.conf /root/.config/geany/
cp /patches/geany/session.conf /root/.config/geany/
cp -r /patches/geany/plugins /root/.config/geany/
patch -R /root/.config/geany/geany.conf /patches/geany/geany.conf.patch
patch -R /root/.config/geany/session.conf /patches/geany/session.conf.patch
EOF


RUN <<EOF
echo -e "export HISTFILESIZE=\nexport HISTSIZE=\nexport HISTTIMEFORMAT='%F %T '" >> /root/.bashrc
EOF

VOLUME ["/data"]

ENTRYPOINT "${WORKDIR}/init.sh" "${WORKDIR}" "/data"
