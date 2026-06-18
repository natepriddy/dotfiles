# Working on natepriddy/dotfiles

Public chezmoi dotfiles repo. Trust-tiered: one source tree, a per-machine
`trust_level` decides what materializes at `chezmoi apply` time.

**This file is about editing the repo.** It is NOT `home/dot_claude/CLAUDE.md` —
that is deployment payload that ships to `~/.claude/CLAUDE.md` and governs Claude
globally. Different job, different file.

## Safety rules (incidents happen here)

**This is a public repo. Fail closed.**

- No secrets, tokens, keys, emails, private paths in source. gitleaks + trufflehog
  are hard CI gates on full history. A leaked credential is permanent.
  Run `gitleaks protect --staged` before pushing to catch leaks at stage time, not
  after — CI scans history, but the staged scan is the guard for the `add -A` risk.
- **Never `git add -A` or `chezmoi add -A`.** The `.chezmoiignore` guards
  (`gh/hosts.yml`, `context7`, `temporalio`, copilot dirs) only protect against
  targeted re-add. Sweeps can stage live creds from `$HOME`. Always stage explicit
  paths: `git add home/dot_zshrc.tmpl home/.chezmoiignore`.
- For multi-file or risky work: **isolated git worktree**, not the live checkout.
  A concurrent `chezmoi apply` or another session doing `add -A` will race you.
- Don't edit deployed files in `$HOME`. Edit source here; the user applies.

## Layout

`.chezmoiroot = home` — the chezmoi source is `home/`, not repo root.

```
home/
  .chezmoi.toml.tmpl    init prompt → trust_level → feature flags
  .chezmoidata.toml     public fail-closed defaults (never put secrets here)
  .chezmoiignore        target-name guards (see gotchas below)
  .chezmoitemplates/    shared partials — Brewfile.base, claude-obsidian.md, …
  .chezmoiscripts/      ordered bootstrap + install scripts
  dot_claude/           → ~/.claude/  (payload: CLAUDE.md, settings, skills)
  dot_config/           → ~/.config/  (mise, nvim, zed, zellij, …)
  dot_zshrc.tmpl        → ~/.zshrc
```

`home/dot_claude/` and `home/dot_config/` are **deployment payload**. Editing them
changes the user's machine, not repo tooling.

## chezmoi gotchas (read before touching templates)

**Two-stage rendering.** Target templates reference `.trust_level` and `.features.*`
which only exist after the init config is rendered. Skipping stage 1 silently renders
as `client-restricted`. Correct render:

```bash
# Stage 1: render the init config
chezmoi execute-template --init \
  --promptChoice "Machine trust level=personal-primary" \
  < home/.chezmoi.toml.tmpl > /tmp/cfg.toml

# Stage 2: render a target against that config
chezmoi execute-template --config /tmp/cfg.toml --source home \
  < home/dot_zshrc.tmpl
```

**`--promptChoice` keys on prompt TEXT, not variable name.** Use
`"Machine trust level=<tier>"` — NOT `"trust_level=<tier>"`. Wrong key silently falls
back to `client-restricted`. Every tier then renders identically; bug is invisible.
Same pattern applies to `--promptBool "Enable Obsidian AI vault bundle=<bool>"` and `--promptString "Git user email=<addr>"`.

**`.chezmoiignore` matches TARGET names, not `dot_` source names.** Write
`.claude/settings.json`, never `dot_claude/settings.json`. Patterns are gitignore
semantics — no inline comments on a pattern line.

**`home/.chezmoitemplates/Brewfile.base` is a plain file — no `{{ }}`.** Kept plain
so `brew bundle check --file=…` and standalone linting work on it. Tier-specific
packages go in the `homebrew_full` block of `run_onchange_after_20-homebrew.sh.tmpl`.

**A gated-off `.sh.tmpl` must still be valid bash** — render it to a shebang only
(`#!/usr/bin/env bash`) for the disabled tier, not empty.

**Renaming a prompt string requires updating it in three places:**
`home/.chezmoi.toml.tmpl`, `scripts/local-validate.sh` (`TRUST_PROMPT` / `OBSIDIAN_BOOL_PROMPT`),
and `.github/workflows/ci.yml`. They must match exactly.

## Test suite

```bash
scripts/local-validate.sh
```

Renders every key template for every trust tier, runs gitleaks, and does a
sandboxed `chezmoi init --apply` in Docker. Never touches real `$HOME`, never pushes.
Run after any multi-file edit.

CI (`.github/workflows/ci.yml`) extends this: 3 trust levels × Linux + macOS,
idempotency, gitleaks, trufflehog. Read the inline comments for authoritative
rationale on prompt-flag semantics and no-op brew/mise shims.

Always test against **`client-restricted` AND one full tier** — they take different
template branches.

For chezmoi, brew, or mise documentation: use the `find-docs` skill (`/find-docs`),
which wraps context7 and handles library resolution automatically.

## Trust tiers

| Tier | Features |
|---|---|
| `personal-primary` | All: homebrew full, mise + runtimes, secrets, ssh_keys |
| `personal-secondary` | homebrew full, mise, secrets (no ssh, no work-git) |
| `company` | homebrew full, mise, secrets, work_git (no ssh) |
| `client-restricted` | **default** — homebrew base only, no runtimes, no secrets, no ssh |

`client-restricted` is the fail-closed default; every machine that never ran init
gets this profile.

Obsidian bundle (`[data.obsidian].ai_vault`) is **independent of trust tier** —
an explicit opt-in flag defaulting false.

## Skills

Skills are **npm-managed via lockfile**, not tracked as source files.

- `home/dot_agents/dot_skill-lock.json` is the only committed artifact — chezmoi manages it
- `run_onchange_after_install-skills.sh.tmpl` reconciles installed skills against the lockfile on every apply
- Never `chezmoi add ~/.agents/skills/**` — the lockfile + install script is the source of truth
- Obsidian-related skills must use `obsidian-` prefix; they are gated off on machines where `obsidian.ai_vault = false`

## Patterns

**macOS defaults — `run_onchange_`, not `run_once_`.**

macOS settings live in `run_onchange_after_70-macos-defaults.sh.tmpl`. Use
`run_onchange_` (not `run_once_`) because `defaults write` is already idempotent
(no-op when the value matches), so re-runs are always safe. Adding a new setting
to the script re-hashes it and automatically re-runs on all machines.

- To add a new setting: append a `defaults write` call with an inline comment.
- To remove a setting you previously added: `defaults delete <domain> <key>` on
  each machine manually — the script only writes, never deletes.
- Terminal needs **Full Disk Access** (System Settings → Privacy & Security →
  Full Disk Access) or Sonoma 14+ silently ignores writes.
- Always `killall Dock` / `killall Finder` at the end so changes take effect.
- Some keys (trackpad, keyboard, accessibility) require logout to apply.
- Key names can change silently on major macOS upgrades — verify with
  `defaults read <domain> <key>` after each upgrade.

**`run_once_` with `--get` guards — "set once, never overwrite".**

Use this for config files (like `~/.gitconfig`) that should bootstrap on a new
machine but never be overwritten by dotfile updates once the user has customised them.

```bash
gc() {
  git config --global --get "$1" >/dev/null 2>&1 || git config --global "$1" "$2"
}
gc user.email "you@example.com"
```

- First run: key absent → sets it.
- Re-run after script change: key present → skips it. Local edits are safe.
- To force-update a key on one machine: `git config --global <key> <value>` manually.
- To add a new key to all future machines: add a `gc` call — existing machines get
  it on next apply; already-set keys on those machines are untouched.
- To push an updated default to ALL machines: wrap it in a new `run_once_` script
  with a different filename (forces a fresh run). Use the same guard pattern there.
