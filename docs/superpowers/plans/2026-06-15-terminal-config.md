# Terminal Config Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add WezTerm (Catppuccin Mocha) and iTerm2 (Dynamic Profile, rose-pine) to chezmoi dotfiles, deploying on all trust tiers.

**Architecture:** WezTerm config is a plain Lua file at `~/.config/wezterm/wezterm.lua`. iTerm2 uses a Dynamic Profile JSON at `~/Library/Application Support/iTerm2/DynamicProfiles/natepriddy.json` — loaded automatically by iTerm on startup, no plist editing required. A `run_onchange` script sets the default profile GUID via `defaults write`. All files deploy unconditionally (no trust gate).

**Tech Stack:** chezmoi, Lua (WezTerm config), JSON (iTerm Dynamic Profile), bash (onchange script)

---

## File Map

| Action | Path |
|--------|------|
| Modify | `home/.chezmoiscripts/run_onchange_after_20-homebrew.sh.tmpl` |
| Create | `home/dot_config/wezterm/wezterm.lua` |
| Create | `home/Library/Application Support/iTerm2/DynamicProfiles/natepriddy.json` |
| Create | `home/.chezmoiscripts/run_onchange_after_50-iterm-defaults.sh.tmpl` |

---

## Task 1: Add iterm2 cask to homebrew_full

**Files:**
- Modify: `home/.chezmoiscripts/run_onchange_after_20-homebrew.sh.tmpl`

- [ ] **Step 1: Add iterm2 to the macOS cask block**

Open `home/.chezmoiscripts/run_onchange_after_20-homebrew.sh.tmpl`. Find the `{{- if eq .chezmoi.os "darwin" }}` block inside the `homebrew_full` tail section. It currently reads:

```
cask "wezterm"
cask "rectangle"
```

Change it to:

```
cask "iterm2"
cask "wezterm"
cask "rectangle"
```

- [ ] **Step 2: Verify the file renders correctly**

```bash
chezmoi execute-template --init \
  --promptChoice "Machine trust level=personal-primary" \
  --promptBool "Enable experimental Obsidian/Claude-memory bundle=false" \
  < home/.chezmoi.toml.tmpl > /tmp/cfg.toml

chezmoi execute-template --config /tmp/cfg.toml --source home \
  < home/.chezmoiscripts/run_onchange_after_20-homebrew.sh.tmpl | grep -E "iterm2|wezterm|rectangle"
```

Expected output contains all three casks.

- [ ] **Step 3: Commit**

```bash
git add home/.chezmoiscripts/run_onchange_after_20-homebrew.sh.tmpl
git commit -m "feat(brew): add iterm2 cask to homebrew_full"
```

---

## Task 2: WezTerm Lua config

**Files:**
- Create: `home/dot_config/wezterm/wezterm.lua`

- [ ] **Step 1: Create the wezterm config directory**

```bash
mkdir -p home/dot_config/wezterm
```

- [ ] **Step 2: Write wezterm.lua**

Create `home/dot_config/wezterm/wezterm.lua` with this content:

```lua
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Colors
config.color_scheme = "Catppuccin Mocha"

-- Font — matches iTerm setup
config.font = wezterm.font("JetBrainsMonoNL Nerd Font", { weight = "Medium" })
config.font_size = 12.0

-- Window
config.window_decorations = "RESIZE"
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }

-- Tab bar
config.enable_tab_bar = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

-- Scrollback
config.scrollback_lines = 10000

-- Cursor
config.default_cursor_style = "BlinkingBlock"

-- Bell
config.audible_bell = "Disabled"

return config
```

- [ ] **Step 3: Verify chezmoi sees the file**

```bash
chezmoi execute-template --config /tmp/cfg.toml --source home \
  < home/dot_config/wezterm/wezterm.lua | head -5
```

Expected: the Lua content (no template directives, so it outputs verbatim).

- [ ] **Step 4: Commit**

```bash
git add home/dot_config/wezterm/wezterm.lua
git commit -m "feat(wezterm): add Catppuccin Mocha config with JetBrains Mono"
```

---

## Task 3: iTerm2 Dynamic Profile

**Files:**
- Create: `home/Library/Application Support/iTerm2/DynamicProfiles/natepriddy.json`

- [ ] **Step 1: Create the directory**

```bash
mkdir -p "home/Library/Application Support/iTerm2/DynamicProfiles"
```

- [ ] **Step 2: Write natepriddy.json**

Create `home/Library/Application Support/iTerm2/DynamicProfiles/natepriddy.json`:

```json
{
  "Profiles": [
    {
      "Guid": "A1B2C3D4-E5F6-7890-ABCD-EF1234567890",
      "Name": "natepriddy",
      "Dynamic Profile Parent Name": "Default",

      "Normal Font": "JetBrainsMonoNLNF-Medium 12",
      "Non Ascii Font": "JetBrainsMonoNLNF-Medium 12",
      "Use Non-ASCII Font": false,

      "Scrollback Lines": 10000,
      "Scrollback in Alternate Screen": false,
      "Unlimited Scrollback": false,

      "Cursor Type": 1,
      "Blinking Cursor": true,

      "Keyboard Map": {},

      "Foreground Color": {
        "Red Component": 0.878431, "Green Component": 0.870588, "Blue Component": 0.956863, "Alpha Component": 1.0, "Color Space": "sRGB"
      },
      "Background Color": {
        "Red Component": 0.098039, "Green Component": 0.090196, "Blue Component": 0.141176, "Alpha Component": 1.0, "Color Space": "sRGB"
      },
      "Bold Color": {
        "Red Component": 0.878431, "Green Component": 0.870588, "Blue Component": 0.956863, "Alpha Component": 1.0, "Color Space": "sRGB"
      },
      "Cursor Color": {
        "Red Component": 0.333333, "Green Component": 0.317647, "Blue Component": 0.411765, "Alpha Component": 1.0, "Color Space": "sRGB"
      },
      "Cursor Text Color": {
        "Red Component": 0.878431, "Green Component": 0.870588, "Blue Component": 0.956863, "Alpha Component": 1.0, "Color Space": "sRGB"
      },
      "Selection Color": {
        "Red Component": 0.164706, "Green Component": 0.156863, "Blue Component": 0.215686, "Alpha Component": 1.0, "Color Space": "sRGB"
      },
      "Selected Text Color": {
        "Red Component": 0.878431, "Green Component": 0.870588, "Blue Component": 0.956863, "Alpha Component": 1.0, "Color Space": "sRGB"
      },
      "Link Color": {
        "Red Component": 0.768627, "Green Component": 0.654902, "Blue Component": 0.905882, "Alpha Component": 1.0, "Color Space": "sRGB"
      },
      "Ansi 0 Color":  { "Red Component": 0.14902,  "Green Component": 0.137255, "Blue Component": 0.227451, "Alpha Component": 1.0, "Color Space": "sRGB" },
      "Ansi 1 Color":  { "Red Component": 0.921569, "Green Component": 0.435294, "Blue Component": 0.572549, "Alpha Component": 1.0, "Color Space": "sRGB" },
      "Ansi 2 Color":  { "Red Component": 0.611765, "Green Component": 0.811765, "Blue Component": 0.847059, "Alpha Component": 1.0, "Color Space": "sRGB" },
      "Ansi 3 Color":  { "Red Component": 0.964706, "Green Component": 0.756863, "Blue Component": 0.466667, "Alpha Component": 1.0, "Color Space": "sRGB" },
      "Ansi 4 Color":  { "Red Component": 0.192157, "Green Component": 0.454902, "Blue Component": 0.560784, "Alpha Component": 1.0, "Color Space": "sRGB" },
      "Ansi 5 Color":  { "Red Component": 0.768627, "Green Component": 0.654902, "Blue Component": 0.905882, "Alpha Component": 1.0, "Color Space": "sRGB" },
      "Ansi 6 Color":  { "Red Component": 0.921569, "Green Component": 0.737255, "Blue Component": 0.729412, "Alpha Component": 1.0, "Color Space": "sRGB" },
      "Ansi 7 Color":  { "Red Component": 0.878431, "Green Component": 0.870588, "Blue Component": 0.956863, "Alpha Component": 1.0, "Color Space": "sRGB" },
      "Ansi 8 Color":  { "Red Component": 0.431373, "Green Component": 0.415686, "Blue Component": 0.52549,  "Alpha Component": 1.0, "Color Space": "sRGB" },
      "Ansi 9 Color":  { "Red Component": 0.921569, "Green Component": 0.435294, "Blue Component": 0.572549, "Alpha Component": 1.0, "Color Space": "sRGB" },
      "Ansi 10 Color": { "Red Component": 0.611765, "Green Component": 0.811765, "Blue Component": 0.847059, "Alpha Component": 1.0, "Color Space": "sRGB" },
      "Ansi 11 Color": { "Red Component": 0.964706, "Green Component": 0.756863, "Blue Component": 0.466667, "Alpha Component": 1.0, "Color Space": "sRGB" },
      "Ansi 12 Color": { "Red Component": 0.192157, "Green Component": 0.454902, "Blue Component": 0.560784, "Alpha Component": 1.0, "Color Space": "sRGB" },
      "Ansi 13 Color": { "Red Component": 0.768627, "Green Component": 0.654902, "Blue Component": 0.905882, "Alpha Component": 1.0, "Color Space": "sRGB" },
      "Ansi 14 Color": { "Red Component": 0.921569, "Green Component": 0.737255, "Blue Component": 0.729412, "Alpha Component": 1.0, "Color Space": "sRGB" },
      "Ansi 15 Color": { "Red Component": 0.878431, "Green Component": 0.870588, "Blue Component": 0.956863, "Alpha Component": 1.0, "Color Space": "sRGB" }
    }
  ]
}
```

- [ ] **Step 3: Verify JSON is valid**

```bash
python3 -m json.tool "home/Library/Application Support/iTerm2/DynamicProfiles/natepriddy.json" > /dev/null && echo "valid JSON"
```

Expected: `valid JSON`

- [ ] **Step 4: Commit**

```bash
git add "home/Library/Application Support/iTerm2/DynamicProfiles/natepriddy.json"
git commit -m "feat(iterm): add Dynamic Profile with rose-pine colors and JetBrains Mono"
```

---

## Task 4: iTerm defaults script (set default profile GUID)

**Files:**
- Create: `home/.chezmoiscripts/run_onchange_after_50-iterm-defaults.sh.tmpl`

- [ ] **Step 1: Write the script**

Create `home/.chezmoiscripts/run_onchange_after_50-iterm-defaults.sh.tmpl`:

```bash
#!/usr/bin/env bash
# Sets the natepriddy Dynamic Profile as iTerm2's default profile.
# Only runs on macOS. The GUID must match natepriddy.json exactly.
# run_onchange_ fires when this file's rendered content changes.
{{- if eq .chezmoi.os "darwin" }}
set -euo pipefail

PROFILE_GUID="A1B2C3D4-E5F6-7890-ABCD-EF1234567890"

# Only apply if iTerm2 is installed
if ! [ -d "/Applications/iTerm.app" ]; then
  echo "iTerm2 not found — skipping default profile setup."
  exit 0
fi

defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "${PROFILE_GUID}"
echo "iTerm2 default profile set to natepriddy (${PROFILE_GUID})."
{{- else }}
# Non-macOS: no-op
echo "Not macOS — skipping iTerm2 defaults."
{{- end }}
```

- [ ] **Step 2: Verify the script renders for both macOS and linux**

```bash
# macOS render (should contain defaults write)
chezmoi execute-template --config /tmp/cfg.toml --source home \
  < home/.chezmoiscripts/run_onchange_after_50-iterm-defaults.sh.tmpl | grep "defaults write"

# Linux render — render with a fake linux config
cat > /tmp/cfg-linux.toml <<'TOML'
[data]
  trust_level = "personal-primary"
[data.features]
  homebrew = true
  homebrew_full = true
[data.obsidian]
  enabled = false
TOML
# Patch os to linux for template test
chezmoi execute-template --config /tmp/cfg-linux.toml --source home \
  < home/.chezmoiscripts/run_onchange_after_50-iterm-defaults.sh.tmpl | grep "Non-macOS"
```

Expected: first grep finds `defaults write`, second finds `Non-macOS`.

Note: the linux render test is approximate — chezmoi's `.chezmoi.os` comes from the real host in execute-template, so the linux branch is validated in CI (multi-OS matrix) rather than locally on macOS.

- [ ] **Step 3: Commit**

```bash
git add home/.chezmoiscripts/run_onchange_after_50-iterm-defaults.sh.tmpl
git commit -m "feat(iterm): set natepriddy Dynamic Profile as default via run_onchange script"
```

---

## Task 5: Dry-run and PR

- [ ] **Step 1: Run chezmoi dry-run to confirm all new files appear**

```bash
chezmoi apply --dry-run --verbose 2>&1 | grep -E "wezterm|iterm|DynamicProfile|natepriddy"
```

Expected: entries for `~/.config/wezterm/wezterm.lua` and `~/Library/Application Support/iTerm2/DynamicProfiles/natepriddy.json`.

- [ ] **Step 2: Run local validate script**

```bash
DOTFILES_SKIP_BREW_BUNDLE=1 bash scripts/local-validate.sh
```

Expected: all trust tier renders pass, no gitleaks hits.

- [ ] **Step 3: Create PR**

```bash
git checkout -b feat/terminal-config
git push -u origin feat/terminal-config
gh pr create \
  --title "feat(terminal): WezTerm Catppuccin Mocha + iTerm2 Dynamic Profile (rose-pine)" \
  --body "Adds WezTerm and iTerm2 config to chezmoi. WezTerm gets Catppuccin Mocha + JetBrains Mono. iTerm2 uses a Dynamic Profile (no plist) with rose-pine colors and an empty Keyboard Map ready to populate. Also adds iterm2 cask to homebrew_full and fixes missing zsh-autosuggestions/zsh-syntax-highlighting brew entries."
```

- [ ] **Step 4: Merge and switch back to main**

```bash
gh pr merge --merge
git checkout main
git pull
```
