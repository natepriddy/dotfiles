#!/usr/bin/env bash
#
# local-validate.sh — SAFE pre-cutover checks for the chezmoi dotfiles repo.
#
# What it does (all sandboxed, all read-only w.r.t. your real machine):
#   1. Render every key template for every trust level — assert zero errors.
#   2. Run gitleaks on the repo if installed (else WARN, don't fail).
#   3. Run `chezmoi init --apply` inside a fresh `ubuntu:24.04` Docker container,
#      into the CONTAINER's own $HOME — never the host.
#
# What it deliberately NEVER does:
#   - It NEVER applies to the real $HOME.
#   - It NEVER runs `git push`, `git commit`, or any network write.
#   - It NEVER sets up Time Machine or touches host system state.
#   - It NEVER needs sudo.
#
# Rendering and the container run use a throwaway sandbox under a temp dir that is
# removed on exit. The host $HOME and the host chezmoi config are never read or
# written for state.
#
# Usage:   scripts/local-validate.sh
# Exit:    0 = all required checks PASS; non-zero = at least one FAIL.

set -euo pipefail

# ── locate repo + source root ────────────────────────────────────────────────
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." >/dev/null 2>&1 && pwd -P)"

# .chezmoiroot tells chezmoi the real source lives under home/. Honour it.
CHEZMOI_ROOT_FILE="${REPO_ROOT}/.chezmoiroot"
if [[ -f "${CHEZMOI_ROOT_FILE}" ]]; then
  SRC_SUBDIR="$(tr -d '[:space:]' < "${CHEZMOI_ROOT_FILE}")"
else
  SRC_SUBDIR="home"
fi
SOURCE_DIR="${REPO_ROOT}/${SRC_SUBDIR}"
INIT_TMPL="${SOURCE_DIR}/.chezmoi.toml.tmpl"

# ── colors / logging ─────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  C_RED=$'\033[31m'; C_GRN=$'\033[32m'; C_YEL=$'\033[33m'; C_BLU=$'\033[34m'; C_RST=$'\033[0m'
else
  C_RED=''; C_GRN=''; C_YEL=''; C_BLU=''; C_RST=''
fi
info()  { printf '%s[ .. ]%s %s\n' "${C_BLU}" "${C_RST}" "$*"; }
pass()  { printf '%s[PASS]%s %s\n' "${C_GRN}" "${C_RST}" "$*"; }
warn()  { printf '%s[WARN]%s %s\n' "${C_YEL}" "${C_RST}" "$*"; }
fail()  { printf '%s[FAIL]%s %s\n' "${C_RED}" "${C_RST}" "$*"; }

# ── result accounting ────────────────────────────────────────────────────────
RESULTS=()           # "PASS|FAIL|WARN<TAB>label"
FAILED=0
record() { RESULTS+=("$1"$'\t'"$2"); [[ "$1" == "FAIL" ]] && FAILED=1; return 0; }

# ── isolated sandbox (auto-removed) ──────────────────────────────────────────
SANDBOX="$(mktemp -d "${TMPDIR:-/tmp}/chezmoi-validate.XXXXXX")"
cleanup() { rm -rf "${SANDBOX}" 2>/dev/null || true; }
trap cleanup EXIT

# Trust levels declared by the init template.
TRUST_LEVELS=(personal-primary personal-secondary company client-restricted)

# IMPORTANT: chezmoi's --promptChoice flag keys on the PROMPT TEXT, not the data
# path. home/.chezmoi.toml.tmpl calls:
#     promptChoiceOnce . "trust_level" "Machine trust level" $choices "client-restricted"
# so the non-interactive override is "Machine trust level=<tier>", NOT
# "trust_level=<tier>" (the latter silently falls back to the default and would
# make every tier validate as client-restricted). If you rename the prompt in the
# template, update this string to match.
TRUST_PROMPT="Machine trust level"

# The trust-bearing templates that must render for every tier.
# (Anything with .trust_level / .features / .chezmoi.os|arch guards.)
KEY_TEMPLATES=(
  "dot_zshrc.tmpl"
  ".chezmoi.toml.tmpl"
  "dot_config/mise/config.toml.tmpl"
  ".chezmoiscripts/run_onchange_after_20-homebrew.sh.tmpl"
  ".chezmoiscripts/run_onchange_after_40-fonts.sh.tmpl"
  "dot_claude/settings.json.tmpl"
)

require_chezmoi() {
  if ! command -v chezmoi >/dev/null 2>&1; then
    fail "chezmoi is not installed on this host — required for template rendering."
    fail "Install it (brew install chezmoi) and re-run."
    record FAIL "prerequisite: chezmoi installed"
    return 1
  fi
  return 0
}

# ─────────────────────────────────────────────────────────────────────────────
# Check 1 — render every key template for every trust level (no $HOME writes)
# ─────────────────────────────────────────────────────────────────────────────
check_render() {
  printf '\n%s== 1. Template render (all trust levels) ==%s\n' "${C_BLU}" "${C_RST}"
  require_chezmoi || return 0

  local render_failed=0
  for trust in "${TRUST_LEVELS[@]}"; do
    info "trust_level=${trust}"

    # Step 1: render the init config template, feeding the chosen tier via
    # --promptChoice (keyed on the PROMPT TEXT — see TRUST_PROMPT above). This
    # produces the exact ~/.config/chezmoi/chezmoi.toml a real ${trust} machine
    # would get, including the derived [data.features.*] flags.
    local cfg="${SANDBOX}/cfg-${trust}.toml"
    if ! chezmoi execute-template --init \
            --promptChoice "${TRUST_PROMPT}=${trust}" \
            < "${INIT_TMPL}" > "${cfg}" 2>"${SANDBOX}/cfg-${trust}.err"; then
      fail "  .chezmoi.toml.tmpl failed to render for ${trust}"
      sed 's/^/        /' "${SANDBOX}/cfg-${trust}.err" || true
      render_failed=1
      continue
    fi

    # Guard: assert the override actually took. If chezmoi's prompt-key semantics
    # ever change, the config would silently fall back to client-restricted and
    # every tier would validate identically — catch that here.
    if ! grep -q "trust_level = \"${trust}\"" "${cfg}"; then
      fail "  rendered config did not record trust_level=${trust} (got: $(grep trust_level "${cfg}" | head -1 | tr -s ' '))"
      fail "  --promptChoice key may be wrong; expected prompt text '${TRUST_PROMPT}'."
      render_failed=1
      continue
    fi

    # Step 2: render each consuming template WITHOUT --init, passing the rendered
    # config via --config so .trust_level / .features.* resolve exactly as on a
    # real ${trust} machine. --destination/--persistent-state stay in the sandbox
    # so nothing reads or writes the host's $HOME or chezmoi state.
    for rel in "${KEY_TEMPLATES[@]}"; do
      local f="${SOURCE_DIR}/${rel}"
      [[ -f "${f}" ]] || { warn "  missing template (skipped): ${rel}"; continue; }

      # The init template is validated by step 1 above; skip re-rendering it here
      # (it needs --init, not --config).
      if [[ "${rel}" == ".chezmoi.toml.tmpl" ]]; then
        printf '        ok  %s (validated via init)\n' "${rel}"
        continue
      fi

      if chezmoi execute-template \
            --config "${cfg}" \
            --source "${SOURCE_DIR}" \
            --destination "${SANDBOX}/dest-${trust}" \
            --persistent-state "${SANDBOX}/state-${trust}.boltdb" \
            < "${f}" > "${SANDBOX}/render.out" 2>"${SANDBOX}/render.err"; then
        printf '        ok  %s\n' "${rel}"
      else
        fail "  ${rel} failed to render for ${trust}"
        sed 's/^/        /' "${SANDBOX}/render.err" || true
        render_failed=1
      fi
    done
  done

  if [[ "${render_failed}" -eq 0 ]]; then
    pass "all key templates render cleanly for all ${#TRUST_LEVELS[@]} trust levels"
    record PASS "template render (all trust levels)"
  else
    fail "one or more templates failed to render"
    record FAIL "template render (all trust levels)"
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Check 2 — gitleaks (WARN if not installed; this is a public repo)
# ─────────────────────────────────────────────────────────────────────────────
check_gitleaks() {
  printf '\n%s== 2. Secret scan (gitleaks) ==%s\n' "${C_BLU}" "${C_RST}"
  if ! command -v gitleaks >/dev/null 2>&1; then
    warn "gitleaks not installed — skipping. Install with: brew install gitleaks"
    warn "CI still runs this gate, but local cutover should not rely on CI alone."
    record WARN "gitleaks (not installed)"
    return 0
  fi

  info "scanning ${REPO_ROOT}"
  if gitleaks detect --source "${REPO_ROOT}" --redact --no-banner \
        --report-path "${SANDBOX}/gitleaks-report.json" > "${SANDBOX}/gitleaks.log" 2>&1; then
    pass "gitleaks found no leaks"
    record PASS "gitleaks (no leaks)"
  else
    fail "gitleaks reported potential secrets — HARD STOP for a public repo"
    sed 's/^/        /' "${SANDBOX}/gitleaks.log" || true
    record FAIL "gitleaks (potential secrets found)"
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Check 3 — Docker ubuntu:24.04 apply INTO THE CONTAINER (never the host)
# ─────────────────────────────────────────────────────────────────────────────
check_docker_apply() {
  printf '\n%s== 3. Docker ubuntu:24.04 apply (sandbox container) ==%s\n' "${C_BLU}" "${C_RST}"

  if ! command -v docker >/dev/null 2>&1; then
    warn "docker not installed — skipping container apply test."
    warn "Install Docker/colima and re-run to validate the Linux/restricted path."
    record WARN "docker apply (docker not installed)"
    return 0
  fi
  if ! docker info >/dev/null 2>&1; then
    warn "docker daemon not reachable — skipping container apply test."
    warn "Start Docker/colima and re-run."
    record WARN "docker apply (daemon not running)"
    return 0
  fi

  # The container gets a COPY of the source mounted READ-ONLY. chezmoi inside the
  # container applies into the container's own /root — the host $HOME is never a
  # target. We pass trust via --promptChoice so init is non-interactive, and test
  # the safest tier (client-restricted) which exercises the no-brew / minimal path.
  info "running init --apply inside ubuntu:24.04 (container \$HOME only)"

  local container_script
  container_script='
set -eu
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq >/dev/null 2>&1
apt-get install -y -qq curl git zsh >/dev/null 2>&1

# Install chezmoi to a writable user-local bin (no sudo, no system mutation).
export BINDIR=/usr/local/bin
sh -c "$(curl -fsLS get.chezmoi.io)" >/dev/null

# The source is mounted READ-ONLY (protecting the host). chezmoi init touches
# git state, so work from a writable COPY inside the container and make it a git
# repo. Apply targets THIS container'\''s $HOME (/root) — never the host.
cp -a /src /work
git -C /work init -q
git -C /work add -A
git -C /work -c user.email=ci@local -c user.name=ci commit -qm "ci snapshot" >/dev/null 2>&1 || true

chezmoi init --apply \
  --source /work \
  --promptChoice "Machine trust level=client-restricted"

echo "---- rendered ~/.zshrc (head) ----"
head -n 20 "$HOME/.zshrc"

echo "---- idempotency: second apply should be a no-op ----"
# `apply` reads the config written by `init` above (trust_level already set), so
# no prompt flag is needed — and `apply` does not accept --promptChoice anyway.
chezmoi apply --source /work
echo "CONTAINER_APPLY_OK"
'

  if docker run --rm \
        -v "${SOURCE_DIR}:/src:ro" \
        ubuntu:24.04 \
        bash -c "${container_script}" > "${SANDBOX}/docker.log" 2>&1; then
    if grep -q "CONTAINER_APPLY_OK" "${SANDBOX}/docker.log"; then
      pass "ubuntu:24.04 init --apply + idempotent re-apply succeeded (container only)"
      record PASS "docker ubuntu apply (sandbox)"
    else
      fail "container ran but did not reach success marker — see log below"
      sed 's/^/        /' "${SANDBOX}/docker.log" || true
      record FAIL "docker ubuntu apply (sandbox)"
    fi
  else
    fail "container apply failed — see log below"
    sed 's/^/        /' "${SANDBOX}/docker.log" || true
    record FAIL "docker ubuntu apply (sandbox)"
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# main
# ─────────────────────────────────────────────────────────────────────────────
main() {
  printf '%s' "${C_BLU}"
  printf 'chezmoi local-validate — SAFE pre-cutover checks\n'
  printf '  repo:   %s\n' "${REPO_ROOT}"
  printf '  source: %s\n' "${SOURCE_DIR}"
  printf '  NOTE:   never touches your real $HOME, never pushes.\n'
  printf '%s' "${C_RST}"

  if [[ ! -d "${SOURCE_DIR}" ]] || [[ ! -f "${INIT_TMPL}" ]]; then
    fail "source dir or init template not found:"
    fail "  expected source:   ${SOURCE_DIR}"
    fail "  expected init tmpl: ${INIT_TMPL}"
    exit 2
  fi

  check_render
  check_gitleaks
  check_docker_apply

  # ── summary ────────────────────────────────────────────────────────────────
  printf '\n%s======================== SUMMARY ========================%s\n' "${C_BLU}" "${C_RST}"
  for r in "${RESULTS[@]}"; do
    local status="${r%%$'\t'*}"
    local label="${r#*$'\t'}"
    case "${status}" in
      PASS) pass "${label}" ;;
      WARN) warn "${label}" ;;
      FAIL) fail "${label}" ;;
    esac
  done
  printf '%s=========================================================%s\n' "${C_BLU}" "${C_RST}"

  if [[ "${FAILED}" -eq 0 ]]; then
    printf '\n%sOVERALL: PASS%s — safe checks clear. (WARN items are skips, not failures.)\n' "${C_GRN}" "${C_RST}"
    printf 'Next HUMAN-GATED steps live in docs/cutover-runbook.md — do NOT automate them.\n'
    exit 0
  else
    printf '\n%sOVERALL: FAIL%s — resolve the FAIL items above before cutover.\n' "${C_RED}" "${C_RST}"
    exit 1
  fi
}

main "$@"
