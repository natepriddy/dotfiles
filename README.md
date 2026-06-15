# natepriddy/dotfiles

Trust-gated, multi-OS dotfiles managed with [chezmoi](https://www.chezmoi.io).

<!-- CI badges placeholder -->
<!-- ![lint](https://img.shields.io/badge/lint-pending-lightgrey) ![apply](https://img.shields.io/badge/apply-pending-lightgrey) -->

One source tree drives every machine I touch — personal laptops, work machines,
and locked-down client boxes — and a single **trust level** chosen at install
time decides how much of it actually materializes. A client-restricted machine
gets a safe, minimal shell and nothing else; my primary laptop gets the full
toolchain, secrets, and SSH keys. Same repo, different blast radius.

## Install

One line. chezmoi is downloaded, this repo is cloned, you're prompted for the
machine's trust level, and everything is applied:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply natepriddy/dotfiles
```

On first run you'll be asked for a **trust level** (see below). The choice is
written to `~/.config/chezmoi/chezmoi.toml` (machine-local, never committed) and
overrides the fail-closed public defaults baked into the repo. A machine that
never finishes init therefore stays at the safest profile.

## Trust tiers

The trust level derives a set of feature flags; everything templated in this
repo gates on those flags. Pick the most restrictive tier that still lets you
work.

| Tier | Homebrew | mise + runtimes | Secrets | SSH keys | Work git identity | Use for |
|------|:--------:|:---------------:|:-------:|:--------:|:-----------------:|---------|
| `personal-primary`   | ✓ | ✓ | ✓ | ✓ | – | My main daily-driver machines |
| `personal-secondary` | ✓ | ✓ | ✓ | – | – | Secondary / spare personal machines |
| `company`            | ✓ | ✓ | ✓ | – | ✓ | Employer-issued machines |
| `client-restricted`  | – | – | – | – | ✓ | Locked-down client environments (**default**) |

- **Homebrew** — installs Homebrew (macOS / Linuxbrew) and runs `brew bundle`.
- **mise + runtimes** — installs [mise](https://mise.jdx.dev) plus the node /
  python / go / java baseline and global npm CLIs from
  `~/.config/mise/config.toml`.
- **Secrets** — enables secret-backed templates (externalized; see below).
- **SSH keys** — materializes SSH key config.
- **Work git identity** — uses the work email / signing identity for git.

`client-restricted` is the default precisely because it's the safe one: no
package installs, no secrets, no keys. You opt *up* into capability, never down
into exposure.

## What happens on apply

chezmoi runs scripts in a defined order around the file apply:

1. **`run_once_before_20-install-deps`** — before any files are written,
   installs just the base toolchain needed to bootstrap: Homebrew (if the tier
   enables it and it's missing) and the mise binary (non-client tiers). Every
   install is `command -v`-guarded, so it's a clean no-op on re-runs and on
   client machines. No packages or runtimes are installed at this stage.
2. **File apply** — your dotfiles, `~/.config/mise/config.toml`, the Brewfile,
   etc. land in `$HOME`.
3. **`run_onchange_after_20-homebrew`** — runs `brew bundle` (idempotent;
   re-runs when the Brewfile changes).
4. **`run_onchange_after_30-mise`** — runs `mise install` to pull the runtimes
   and npm globals declared in the now-present mise config (re-runs when that
   config changes).

## Daily workflow

```sh
chezmoi update          # pull latest from the repo + re-apply
chezmoi edit <file>     # edit the SOURCE of a managed file, then apply
chezmoi re-add          # pull live edits in $HOME back into the source tree
chezmoi diff            # preview what apply would change
chezmoi apply           # apply pending changes
```

Edit the source, not the live file, when you can (`chezmoi edit`). When you've
tweaked something in place and want to keep it, `chezmoi re-add` pulls it back.

## Neovim plugin lockfile

The Neovim config (LazyVim) ships its plugin lockfile,
`~/.config/nvim/lazy-lock.json`, as a managed file. That makes plugin versions
reproducible across machines:

1. On one machine, update plugins as usual: `:Lazy update`. Lazy rewrites
   `lazy-lock.json`.
2. `chezmoi re-add ~/.config/nvim/lazy-lock.json` to capture the new pins, then
   commit and push.
3. On every other machine: `chezmoi update` to receive the new lockfile, then
   `:Lazy restore` inside Neovim to pin plugins to exactly those versions.

Update on one machine, restore on the rest — no version drift.

## Secrets

No secrets live in this repo — it's public and fail-closed. Secret-backed
templates are gated behind the `secrets` feature flag and resolve through an
external provider (age-encrypted files / 1Password). Secret externalization
lands in **v2**; until then, secret-dependent files simply don't render on tiers
where the flag is off.

Two low-sensitivity, machine-local values feed `~/.claude/settings.json` and
default to empty (fail-closed) in `.chezmoidata.toml` — set the real values
per-machine in `~/.config/chezmoi/chezmoi.toml` under `[data.claude]`:

| Key                       | Empty (default) behaviour                                | Set behaviour                                            |
| ------------------------- | -------------------------------------------------------- | ------------------------------------------------------- |
| `claude.context7_api_key` | `CONTEXT7_API_KEY` omitted; ctx7 runs unauthenticated    | key is emitted into `settings.json` `env`               |
| `claude.plugins_dir`      | only official plugins load                               | abs path enables the `nate-claude` marketplace + council |

These are machine-local config values, not committed secrets; v2 may move the
API key behind the encrypted provider.

## Layout

```
.chezmoiroot              -> home   (source tree lives under home/)
home/
  .chezmoidata.toml       public, fail-closed defaults
  .chezmoi.toml.tmpl      init prompt -> per-machine trust level + flags
  .chezmoiscripts/        ordered bootstrap / install scripts
  dot_config/             ~/.config/*  (mise, nvim, …)
  dot_zshrc.tmpl          ~/.zshrc
```
