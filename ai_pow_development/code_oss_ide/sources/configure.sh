#!/bin/bash
set -euo pipefail

sources_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
user_data_dir=${CODE_OSS_USER_DATA_DIR:-/root/.config/Code - OSS}
continue_dir=${CONTINUE_GLOBAL_DIR:-${HOME}/.continue}

mkdir -p "${user_data_dir}/User" "$continue_dir" \
    "${CODEX_HOME:-${HOME}/.codex}" "${CLAUDE_CONFIG_DIR:-${HOME}/.claude}"

# Seed empty/no-copy volumes, but preserve existing settings, including JSONC.
if [[ ! -e "${user_data_dir}/User/settings.json" ]]; then
    install -m 0600 "${sources_dir}/settings.json" "${user_data_dir}/User/settings.json"
fi
# An existing legacy Continue config is also a user choice.
if [[ ! -e "${continue_dir}/config.yaml" && ! -e "${continue_dir}/config.json" ]]; then
    install -m 0600 "${sources_dir}/continue.yaml" "${continue_dir}/config.yaml"
fi
