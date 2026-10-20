#!/bin/bash
# Run inside the built image without a display or AI credentials.
set -euo pipefail

sources_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
scratch_dir=$(mktemp -d)
trap 'rm -rf -- "$scratch_dir"' EXIT

code --version
clangd --version
lldb --version
installed=$(code --list-extensions | tr '[:upper:]' '[:lower:]')
while IFS= read -r extension || [[ -n "$extension" ]]; do
    [[ -z "$extension" || "$extension" == \#* ]] && continue
    grep -Fxiq -- "$extension" <<< "$installed"
done < "${sources_dir}/extensions.txt"

# Confirm a fresh/no-copy volume is seeded and user edits survive subsequent starts.
export CODE_OSS_USER_DATA_DIR="${scratch_dir}/Code - OSS"
export CONTINUE_GLOBAL_DIR="${scratch_dir}/continue"
export CODEX_HOME="${scratch_dir}/codex"
export CLAUDE_CONFIG_DIR="${scratch_dir}/claude"
"${sources_dir}/configure.sh"
cmp "${sources_dir}/settings.json" "${CODE_OSS_USER_DATA_DIR}/User/settings.json"
cmp "${sources_dir}/continue.yaml" "${CONTINUE_GLOBAL_DIR}/config.yaml"
printf '// user JSONC settings\n{}\n' > "${CODE_OSS_USER_DATA_DIR}/User/settings.json"
printf 'name: User config\n' > "${CONTINUE_GLOBAL_DIR}/config.yaml"
"${sources_dir}/configure.sh"
grep -Fxq '// user JSONC settings' "${CODE_OSS_USER_DATA_DIR}/User/settings.json"
grep -Fxq 'name: User config' "${CONTINUE_GLOBAL_DIR}/config.yaml"
rm "${CONTINUE_GLOBAL_DIR}/config.yaml"
printf '{}\n' > "${CONTINUE_GLOBAL_DIR}/config.json"
"${sources_dir}/configure.sh"
test ! -e "${CONTINUE_GLOBAL_DIR}/config.yaml"

# Exercise the actual C++ and Python toolchains, not just package presence.
mkdir -p "${scratch_dir}/project"
cat > "${scratch_dir}/project/CMakeLists.txt" <<'EOF'
cmake_minimum_required(VERSION 3.20)
project(smoke LANGUAGES CXX)
add_executable(smoke main.cpp)
EOF
printf 'int main() { return 0; }\n' > "${scratch_dir}/project/main.cpp"
cmake -S "${scratch_dir}/project" -B "${scratch_dir}/build" -G Ninja \
    -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build "${scratch_dir}/build"
"${scratch_dir}/build/smoke"
clangd --check="${scratch_dir}/project/main.cpp" --compile-commands-dir="${scratch_dir}/build"
printf 'def test_smoke():\n    assert 2 + 2 == 4\n' > "${scratch_dir}/test_smoke.py"
python -m pytest -q -p no:cacheprovider "${scratch_dir}/test_smoke.py"

echo "Code OSS image checks passed"
