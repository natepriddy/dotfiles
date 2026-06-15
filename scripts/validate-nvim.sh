#!/usr/bin/env bash
# Validate the nvim config in a throwaway Docker container.
# Runs headless Neovim with Lazy.nvim — installs plugins, then checks for
# startup errors. Requires Docker. Takes ~5 minutes on first run (plugin download).
#
# Usage:
#   scripts/validate-nvim.sh           # full install + startup check
#   scripts/validate-nvim.sh --quick   # syntax check only, no plugin install
set -euo pipefail

QUICK=0
[[ "${1:-}" == "--quick" ]] && QUICK=1

NVIM_SOURCE="$(cd "$(dirname "$0")/.." && pwd)/home/dot_config/nvim"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker not found — install Docker Desktop first." >&2
  exit 1
fi

echo "==> Building validation image…"
docker build --quiet -t dotfiles-nvim-validate - << 'DOCKERFILE'
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git gcc make unzip ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install latest Neovim stable via GitHub releases
RUN curl -fsSL \
    "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz" \
    -o /tmp/nvim.tar.gz \
  && tar -xzf /tmp/nvim.tar.gz -C /opt \
  && ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim \
  && rm /tmp/nvim.tar.gz

RUN nvim --version | head -1
DOCKERFILE

echo "==> Neovim version in container:"
docker run --rm dotfiles-nvim-validate nvim --version | head -1

if [[ "${QUICK}" == "1" ]]; then
  echo ""
  echo "==> Quick check: Lua config syntax (no plugin install)…"
  docker run --rm \
    -v "${NVIM_SOURCE}:/root/.config/nvim:ro" \
    -e HOME=/root \
    dotfiles-nvim-validate \
    nvim --headless \
      -c "lua print('Neovim started — Lua runtime OK')" \
      -c "qa!" 2>&1
  echo "Quick check passed."
  exit 0
fi

echo ""
echo "==> Full check: installing plugins via Lazy.nvim (~5 min)…"
docker run --rm \
  -v "${NVIM_SOURCE}:/root/.config/nvim:ro" \
  -e HOME=/root \
  dotfiles-nvim-validate \
  sh -c '
    set -e
    # Bootstrap lazy.nvim
    nvim --headless -c "Lazy! install" -c "qa!" 2>&1 | tee /tmp/lazy-install.log || true

    echo ""
    echo "==> Startup error check…"
    # Re-launch with plugins installed; any errors land on stderr
    errors=$(nvim --headless -c "qa!" 2>&1 | grep -iE "error|Error|failed|stack trace" || true)
    if [ -n "${errors}" ]; then
      echo "ERRORS FOUND:"
      echo "${errors}"
      exit 1
    fi
    echo "No startup errors detected."
  '

echo ""
echo "Validation complete."
