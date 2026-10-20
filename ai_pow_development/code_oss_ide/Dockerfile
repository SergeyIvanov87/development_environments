# syntax=docker/dockerfile:1
ARG BASE_IMAGE=is140608/sys_devel_env:latest
FROM ${BASE_IMAGE}

ENV WORKDIR=/ \
    CODE_OSS_USER_DATA_DIR="/root/.config/Code - OSS" \
    CODE_OSS_EXTENSIONS_DIR=/opt/code-oss/extensions \
    CLAUDE_CONFIG_DIR=/root/.claude \
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

WORKDIR /

RUN <<'EOF'
set -eu
pacman -Syu --noconfirm --needed code clang lldb cmake ninja dbus
pacman -Scc --noconfirm
rm -rf /var/lib/pacman/sync/* /root/.cache/* /tmp/*
EOF

COPY ai_pow_development/code_oss_ide/sources/ /opt/code-oss/

RUN <<'EOF'
set -eu
install -m 0755 /opt/code-oss/code.sh /usr/local/bin/code
chmod 0755 /opt/code-oss/*.sh
/opt/code-oss/configure.sh
EOF

# Install once at build time, rather than downloading at every startup.
# Arch's Code OSS package uses Open VSX, not Microsoft's Marketplace.
RUN <<'EOF'
set -eu
/opt/code-oss/install_extensions.sh
rm -rf /root/.cache/* /tmp/* "${CODE_OSS_USER_DATA_DIR}/logs"
EOF

ARG GIT_COMMIT=unknown
ARG CREATED_TS=unknown
LABEL org.opencontainers.image.title="Code OSS C++/Python development environment" \
      org.opencontainers.image.source="https://github.com/SergeyIvanov87/development_environments" \
      org.opencontainers.image.description="Code OSS with clangd, CodeLLDB, Pyright, Ruff, Continue, Codex and Claude Code" \
      org.opencontainers.image.created=${CREATED_TS} \
      org.opencontainers.image.revision=${GIT_COMMIT} \
      org.opencontainers.image.documentation="https://github.com/SergeyIvanov87/development_environments/blob/main/ai_pow_development/code_oss_ide/README.md"

# As in the other desktop images, root is intended for use with rootless Docker.
# Keep bundled extensions in the image so new releases do not reuse stale copies.
VOLUME ["/data", "/sshkeys", "/root/.config/Code - OSS", "/root/.continue", "/root/.codex", "/root/.claude"]

ENTRYPOINT ["/opt/code-oss/init.sh"]
CMD ["/data"]
