#!/usr/bin/env bash
# audit-macos-defaults.sh — reads current macOS defaults and reports drift
# from the desired state defined in run_onchange_after_70-macos-defaults.sh.tmpl.
#
# Usage: bash scripts/audit-macos-defaults.sh
# Exit: 0 if all pass, 1 if any drift detected.
set -euo pipefail

[[ "$(uname)" == "Darwin" ]] || { echo "macOS only"; exit 1; }

###############################################################################
# Counters
###############################################################################

_pass=0
_fail=0

###############################################################################
# check <domain> <key> <expected_value> <description>
#
# expected_value conventions (mirror defaults write flags):
#   boolean:  "1" (true) or "0" (false)  — defaults stores bools as integers
#   integer:  the numeric string          — compared with -eq
#   string:   the literal string          — compared with ==
#
# Comparison strategy:
#   - If expected_value is purely numeric, use arithmetic -eq (handles int/bool).
#   - Otherwise use string ==.
###############################################################################
check() {
  local domain="$1"
  local key="$2"
  local expected="$3"
  local description="$4"

  local current
  current="$(defaults read "${domain}" "${key}" 2>/dev/null || echo "__MISSING__")"

  local ok=false
  if [[ "${expected}" =~ ^-?[0-9]+$ ]]; then
    # Numeric comparison — covers -int and -bool (stored as 0/1)
    if [[ "${current}" != "__MISSING__" ]] && (( current == expected )); then
      ok=true
    fi
  else
    # String comparison
    if [[ "${current}" == "${expected}" ]]; then
      ok=true
    fi
  fi

  if "${ok}"; then
    echo "✓ ${description}"
    (( _pass++ )) || true
  else
    echo "✗ ${description} (expected: ${expected}, got: ${current})"
    (( _fail++ )) || true
  fi
}

###############################################################################
# Dock
###############################################################################

check com.apple.dock tilesize          "21"      "Dock icon size = 21px"
check com.apple.dock orientation       "right"   "Dock position = right"
check com.apple.dock magnification     "1"       "Dock magnification enabled"
check com.apple.dock show-recents      "0"       "Dock recent apps hidden"

###############################################################################
# Trackpad
###############################################################################

check com.apple.AppleMultitouchTrackpad \
      Clicking "1" "Trackpad tap-to-click (AppleMultitouchTrackpad)"

check com.apple.driver.AppleBluetoothMultitouch.trackpad \
      Clicking "1" "Trackpad tap-to-click (Bluetooth driver)"

check NSGlobalDomain \
      com.apple.swipescrolldirection "0" "Scroll direction = traditional (not natural)"

###############################################################################
# Finder
###############################################################################

check com.apple.finder AppleShowAllFiles    "1"     "Finder shows hidden files"
check com.apple.finder ShowPathbar          "1"     "Finder path bar visible"
check com.apple.finder FXPreferredViewStyle "Nlsv"  "Finder default view = list"
check com.apple.finder NewWindowTarget      "PfAF"  "Finder new window target = All Files"

###############################################################################
# Summary
###############################################################################

total=$(( _pass + _fail ))
echo ""
echo "Passed: ${_pass} / ${total}"

if (( _fail > 0 )); then
  echo ""
  echo "Drift detected. Re-run 'chezmoi apply' (or run the macOS defaults script"
  echo "directly) to apply desired values. Ensure Terminal has Full Disk Access"
  echo "first (System Settings → Privacy & Security → Full Disk Access)."
  exit 1
fi
