---
name: chezmoi-safe-apply
description: >
  Safely apply chezmoi changes to $HOME by previewing diff first, identifying
  destructive changes, and offering targeted apply over untargeted. Use when
  user says "chezmoi apply", "apply dotfiles", "sync dotfiles", "/chezmoi-safe-apply",
  or when a chezmoi change is about to materialize. Prevents accidental
  reversion of live-edited tracked files (CLAUDE.md, settings.json) and
  loss of runtime drift (enabledPlugins, marketplaces, model preferences).
---

# Chezmoi Safe Apply

Wrap `chezmoi apply` with diff preview, destructive-change detection, and targeted-apply recommendations. Never run untargeted `chezmoi apply` without preview.

## Steps

1. **Detect chezmoi presence**: `command -v chezmoi >/dev/null` — error if missing.
2. **Show diff first**: `chezmoi diff` — capture and present to user.
3. **Classify changes** as additive vs destructive:
   - **Additive** (safe to apply): new files, new directories, additions to existing files (lines prefixed `+` only)
   - **Destructive** (needs confirmation): file deletions, in-place modifications, lines prefixed `-`, especially in `CLAUDE.md`, `settings.json`, or any file containing runtime state
4. **Identify runtime drift** in destructive changes:
   - `settings.json`: `enabledPlugins`, `extraKnownMarketplaces`, `model`, `permissions.ask` — Claude Code runtime writes, usually want to keep live state
   - `CLAUDE.md`: live charter edits from session work
   - `*.local.json`: machine-local config never tracked
5. **Recommend path**:
   - All additive → `chezmoi apply` is safe
   - Destructive + drift in live state → recommend `chezmoi re-add <path>` first to capture drift into source, then apply
   - Destructive + intentional source change → recommend targeted `chezmoi apply <subtree>` for blast-radius control
6. **Execute chosen path** after user confirms.
7. **Verify**: show `chezmoi diff` again (should be empty for applied paths) and brief summary of materialized files.

## Decision Flow

```
chezmoi diff
   │
   ├── empty? → "no changes" exit
   │
   ├── all additive? → confirm + chezmoi apply
   │
   └── destructive changes?
       │
       ├── inspect: does $HOME have drift worth keeping?
       │     yes → chezmoi re-add <path>, re-diff, repeat
       │      no → continue
       │
       ├── prefer targeted apply: chezmoi apply <subtree>
       │
       └── final confirm + apply
```

## Common Drift Sources

- `~/.claude/settings.json` ← Claude Code writes `enabledPlugins`, `extraKnownMarketplaces`, `model`, `permissions.ask`
- `~/.claude/CLAUDE.md` ← live session charter edits before sync
- `~/.gitconfig` ← `git config` invocations
- `~/.ssh/known_hosts` ← never track; should be gitignored

## Rules

- **Never run `chezmoi apply` untargeted without showing diff first.**
- **Never `chezmoi apply ~/.claude/settings.json` without first inspecting for runtime drift.**
- If user says "just apply everything", run `chezmoi diff` and require explicit confirmation per destructive change.
- Print the exact apply command before running it.
- If `chezmoi diff` returns non-zero, surface error to user — don't proceed.

## Output Format

```
CHEZMOI APPLY PREVIEW
Diff summary: <N files changed, M additive, K destructive>

Destructive changes:
  - <path>: <what would change> [DRIFT: <runtime state at risk>]

Recommendation: <targeted/full/re-add-first>
Command: <exact command>

Confirm to apply? [yes / no / re-add first]
```
