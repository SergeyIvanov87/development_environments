#!/bin/bash
set -euo pipefail

sources_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
while IFS= read -r extension || [[ -n "$extension" ]]; do
    [[ -z "$extension" || "$extension" == \#* ]] && continue
    code --install-extension "$extension" --force
done < "${sources_dir}/extensions.txt"

# Some CLI failures only emit a message. Fail the build on a missing extension.
installed=$(code --list-extensions | tr '[:upper:]' '[:lower:]')
while IFS= read -r extension || [[ -n "$extension" ]]; do
    [[ -z "$extension" || "$extension" == \#* ]] && continue
    if ! grep -Fxiq -- "$extension" <<< "$installed"; then
        echo "Required extension was not installed: $extension" >&2
        exit 1
    fi
done < "${sources_dir}/extensions.txt"
