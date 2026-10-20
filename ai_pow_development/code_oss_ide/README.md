# Code OSS C++/Python IDE

The open-source build of **Visual Studio Code**, packaged as Arch Linux's `code`
package, on the same `is140608/sys_devel_env` base as the Codex and Cursor images.
This is a desktop IDE for Linux X11/XWayland, not a web IDE or Microsoft Visual
Studio. Use rootless Docker, as with the other images in this repository.

## Build and run

Run from the repository root:

```sh
docker buildx build --load -f ai_pow_development/code_oss_ide/Dockerfile \
  -t is140608/code_oss_ide_env:latest .
ai_pow_development/code_oss_ide/run.sh /absolute/path/to/workspace my-project
```

The host needs Docker, `xauth`, and an X11 display with a valid authorization
cookie (`DISPLAY` set). The launcher forwards that cookie without granting all
local clients access using `xhost`. Workspace paths containing spaces are supported.
For a different image tag, set `CODE_OSS_IMAGE`. See logs with:

```sh
docker logs -f code_oss_ide_env_my-project
```

The launcher creates named volumes for settings, Continue configuration,
Codex/Claude state, and SSH keys. These volumes are shared between containers
started by this launcher. The editor stores secrets with its `basic` password
store because a desktop keyring is not provided; treat the settings and AI state
volumes as sensitive. No tokens or model weights are baked into the image.

## Language tooling

All seven requested extensions are installed during the image build:

| Extension | Purpose |
| --- | --- |
| `llvm-vs-code-extensions.vscode-clangd` | C++ completion, navigation, clang-tidy |
| `vadimcn.vscode-lldb` | C++ debugging |
| `twxs.cmake` | CMake syntax support |
| `ms-python.python` | Python interpreter selection and test integration |
| `ms-pyright.pyright` | Python language server and type checking |
| `charliermarsh.ruff` | Python linting and formatting on save |
| `Continue.continue` | AI inline completion, chat and edits |

`ms-python.debugpy` adds Python debugging. System `clang` (including `clangd`),
LLDB, CMake and Ninja are installed alongside the base image's GCC, Python and
pytest. Generate `compile_commands.json` for clangd, for example:

```sh
cmake -S . -B build -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

The supplied `settings.json` is installed at
`/root/.config/Code - OSS/User/settings.json`. It disables Microsoft C++
IntelliSense, configures clangd and Pyright, enables Ruff formatting on save and
Continue inline suggestions, and disables editor/Continue telemetry.
`python.languageServer` is `None` because the standalone Pyright extension
provides the language server; `Pyright` is not a valid value for that setting in
the Python extension. This also avoids starting a second server through Pylance.

Extensions come from [Open VSX](https://open-vsx.org/) using Code OSS's default
registry. Builds install the latest compatible versions and fail if any required
extension is missing. Bundled extensions live in `/opt/code-oss/extensions`,
outside the persistent settings volume, so rebuilding updates them. Extensions
you install manually in a running container need to be added to `extensions.txt`
to retain them when recreating it. No additional theme, language pack, standalone
AI CLI, model runtime, or model weights are added.

## AI completion and chat

Continue is preconfigured in `/root/.continue/config.yaml` with two
[Ollama models](https://docs.continue.dev/customize/model-providers/top-level/ollama):

- `qwen2.5-coder:1.5b` for inline completion.
- `qwen2.5-coder:7b` for chat and edits.

Install Ollama on the host or a separate inference machine and download the models
there (not inside this image):

```sh
ollama pull qwen2.5-coder:1.5b
ollama pull qwen2.5-coder:7b
```

The default endpoint is `http://host.docker.internal:11434`; the launcher maps
that hostname to the Docker host. The Ollama listener must accept connections
from the container. Its usual loopback-only listener is not accessible over the
Docker bridge: bind it to a reachable host interface and restrict access to your
Docker network with the host firewall. With rootless Docker, host reachability
depends on the networking backend; set `apiBase` to an address reachable from
that container if the default host mapping is unavailable. Alternatively, change
both `apiBase` entries to a remote Ollama endpoint.

Completion and chat require a reachable server with the configured models. To use
a hosted provider, replace the model blocks following Continue's
[configuration reference](https://docs.continue.dev/reference) and store keys in
`/root/.continue/.env` using `${{ secrets.KEY_NAME }}` references. Credentials are
configured at runtime. Existing Continue YAML or legacy JSON configurations and
editor settings are preserved when the container starts; delete a config file
to seed that file from image defaults again.

## Codex and Claude Code

Two native agent integrations are also installed from Open VSX:

- [`openai.chatgpt`](https://open-vsx.org/extension/openai/chatgpt): open the Codex
  sidebar and sign in with ChatGPT or configure your OpenAI API access. Shared
  agent settings and state persist in `/root/.codex`. See the
  [Codex IDE documentation](https://developers.openai.com/codex/ide).
- [`Anthropic.claude-code`](https://open-vsx.org/extension/Anthropic/claude-code):
  open the Claude Code panel and sign in, or supply `ANTHROPIC_API_KEY` or
  `CLAUDE_CODE_OAUTH_TOKEN` at runtime. `CLAUDE_CONFIG_DIR=/root/.claude` persists
  agent configuration and sessions. Nonessential traffic is disabled. See the
  [Claude Code extension documentation](https://code.claude.com/docs/en/vs-code).

The launcher forwards these environment variables, plus `OPENAI_API_KEY`, only
when they are present in the host environment. Each extension uses its bundled
agent executable, avoiding separate CLI installations. Agent authentication is
independent of Continue's model configuration; a ChatGPT/Claude subscription does
not configure an Ollama server or a hosted Continue provider. Keep each agent's
normal permission prompts when editing or executing code.

## SSH and persistence

To reuse an SSH key, place `github_sshkey` in the SSH volume at `/sshkeys` with
mode `0600`. Startup adds a GitHub identity entry only if `~/.ssh/config` does not
already exist. You can create the key from the IDE terminal and register its
public key with GitHub. Encrypted keys prompt normally when used; no key creation
or blocking authentication dialog runs during startup.

## Checks and publishing

The pull-request workflow builds the new image without pushing, verifies all
extensions, compiles/runs a CMake C++ project, runs clangd and a Python test,
checks config persistence, and starts the actual IDE under Xvfb. Live AI requests
and interactive authentication require your own credentials and are not CI tests.

To run the headless image checks manually after building:

```sh
docker run --rm --entrypoint /opt/code-oss/check.sh is140608/code_oss_ide_env:latest
```

The release workflow publishes `is140608/code_oss_ide_env` with the release
version, major/minor and `latest` tags (excluding prereleases for `latest`) and
generates an artifact attestation using the existing Docker Hub secrets.
