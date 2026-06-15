#!/usr/bin/env bash
# Run a single chezmoi bootstrap step by name without re-running everything.
# Useful when a run_once_ or run_onchange_ script needs to be re-executed
# manually (e.g. after brew was installed outside of chezmoi).
#
# Usage: scripts/run-step.sh <step>
#   step: homebrew | mise | fonts | gitconfig | iterm | macos-defaults
#
# The script resolves the source dir via `chezmoi source-path`, renders the
# matching .sh.tmpl against your live config, and pipes it to bash.

set -euo pipefail

STEP="${1:-}"

if [ -z "${STEP}" ]; then
  echo "Usage: $0 <step>"
  echo ""
  echo "Available steps:"
  echo "  all           — run every step below in order"
  echo "  homebrew      — brew bundle (base + full tail)"
  echo "  mise          — mise install (runtimes + npm globals)"
  echo "  fonts         — Nerd Fonts install"
  echo "  gitconfig     — git global config bootstrap"
  echo "  iterm         — iTerm2 DynamicProfile default"
  echo "  macos-defaults — macOS system defaults (Dock, Finder, Trackpad)"
  exit 1
fi

if ! command -v chezmoi >/dev/null 2>&1; then
  echo "chezmoi not found — add it to PATH first." >&2
  exit 1
fi

SOURCE="$(chezmoi source-path)"
SCRIPTS="${SOURCE}/.chezmoiscripts"

run_step() {
  local step="$1" file
  case "${step}" in
    homebrew)       file="${SCRIPTS}/run_onchange_after_20-homebrew.sh.tmpl" ;;
    mise)           file="${SCRIPTS}/run_onchange_after_30-mise.sh.tmpl" ;;
    fonts)          file="${SCRIPTS}/run_onchange_after_40-fonts.sh.tmpl" ;;
    iterm)          file="${SCRIPTS}/run_onchange_after_50-iterm-defaults.sh.tmpl" ;;
    macos-defaults) file="${SCRIPTS}/run_onchange_after_70-macos-defaults.sh.tmpl" ;;
    gitconfig)      file="${SCRIPTS}/run_once_after_60-gitconfig.sh.tmpl" ;;
    *)
      echo "Unknown step: ${step}" >&2
      echo "Run '$0' with no arguments to see available steps." >&2
      exit 1
      ;;
  esac

  if [ ! -f "${file}" ]; then
    echo "Script not found: ${file}" >&2
    exit 1
  fi

  echo "==> Running step: ${step}"
  echo "    Source: ${file}"
  echo ""
  chezmoi execute-template < "${file}" | bash
}

case "${STEP}" in
  all)
    for s in homebrew mise fonts gitconfig iterm macos-defaults; do
      run_step "${s}"
    done
    ;;
  *)
    run_step "${STEP}"
    ;;
esac
