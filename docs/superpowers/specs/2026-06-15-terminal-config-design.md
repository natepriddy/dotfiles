# Terminal Config Design — WezTerm + iTerm2

**Date:** 2026-06-15
**Status:** Approved

---

## Scope

Add WezTerm (Catppuccin Mocha) and iTerm2 (Dynamic Profile — rose-pine, keybindings) to chezmoi dotfiles. Deploys on all trust tiers. Also fixes missing zsh plugin brew entries.

---

## 1. Brew additions

### `Brewfile.base` (all tiers)
- `zsh-autosuggestions` — already referenced in `.zshrc`, was missing from brew ✓ (done)
- `zsh-syntax-highlighting` — same ✓ (done)

### `homebrew_full` macOS cask block
- `iterm2` — add alongside `wezterm` (which is already there)

---

## 2. WezTerm config

**Source:** `home/dot_config/wezterm/wezterm.lua`
**Target:** `~/.config/wezterm/wezterm.lua`
**Trust gate:** none — deploys everywhere, harmless where WezTerm isn't installed

### Settings
- Color scheme: `"Catppuccin Mocha"` (built-in, no plugin required)
- Font: JetBrains Mono NL NF Medium, size 12 (matches iTerm)
- Font fallback: system monospace
- Scrollback: 10,000 lines
- Window decorations: `"RESIZE"` (no title bar chrome on macOS)
- Tab bar: enabled, bottom position
- Default cursor: block, blinking

---

## 3. iTerm2 Dynamic Profile

**Source:** `home/Library/Application Support/iTerm2/DynamicProfiles/natepriddy.json`
**Target:** `~/Library/Application Support/iTerm2/DynamicProfiles/natepriddy.json`
**Trust gate:** none — deploys everywhere, iTerm ignores it where not installed

### Why Dynamic Profiles
Full plist management is fragile across machines (GUIDs, session state, window positions change on every quit). Dynamic Profiles are plain JSON, loaded automatically by iTerm on startup, and never conflict with machine-local state.

### Profile contents
- `Guid`: stable UUID (generated once, hardcoded)
- `Name`: `"natepriddy"`
- `Dynamic Profile Parent Name`: `"Default"` — inherits unset keys from Default
- Font: JetBrains Mono NL NF Medium 12pt
- Colors: rose-pine palette extracted from current `~/Library/Preferences/com.googlecode.iterm2.plist`
- Cursor: block, blinking
- Scrollback lines: 10,000
- Scrollback in alternate screen: false
- `Keyboard Map`: empty dict (ready to populate — re-add via `chezmoi re-add ~/Library/Application\ Support/iTerm2/DynamicProfiles/natepriddy.json`)

### Making it the default
Set `"Default Bookmark Guid"` in `com.googlecode.iterm2` to match the profile GUID via a `run_onchange` script using `defaults write`. This makes the Dynamic Profile the active default profile on first apply.

---

## 4. Chezmoi structure (new files)

```
home/
  dot_config/
    wezterm/
      wezterm.lua
  Library/
    Application Support/
      iTerm2/
        DynamicProfiles/
          natepriddy.json
  .chezmoiscripts/
    run_onchange_after_50-iterm-defaults.sh.tmpl   # sets Default Bookmark Guid
```

---

## 5. Out of scope

- Global iTerm preferences (update settings, hotkey window, general UI) — plist-managed, changes too often
- WezTerm multiplexing / tmux integration — separate concern
- Linux-specific terminal config

---

## Implementation order

1. Add `iterm2` cask to `homebrew_full`
2. Write `wezterm.lua`
3. Extract rose-pine colors from plist → write `natepriddy.json`
4. Write `run_onchange_after_50-iterm-defaults.sh.tmpl`
5. PR, merge, test with `chezmoi apply --dry-run`
