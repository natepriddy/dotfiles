---
name: plugin-audit
description: >
  Audit installed Claude Code plugins, agents, and skills against marketplace
  catalogs. Identify duplicates, gaps, broken symlinks, and overlap with
  third-party skill collections. Use when user says "audit my plugins",
  "what skills do I have", "compare against marketplace", "find missing skills",
  "/plugin-audit", or after installing new plugins. Generates an actionable
  report with install/skip/remove recommendations.
---

# Plugin Audit

Compare what's installed (plugins, agents, skills) against what's available (marketplace, third-party skill repos) and what's expected (charter, MEMORY.md references). Surface gaps, duplicates, and broken state.

## Steps

1. **Inventory installed plugins**:
   - Read `~/.claude/plugins/installed_plugins.json`
   - List enabled vs disabled (from `~/.claude/settings.json` → `enabledPlugins`)
2. **Inventory known marketplaces**:
   - Read `~/.claude/plugins/known_marketplaces.json`
   - For each: read its `marketplace.json` to enumerate available plugins
3. **Inventory personal skills**:
   - `ls ~/.claude/skills/` — distinguish real dirs from symlinks
   - For symlinks, use `test -e` to detect broken targets
4. **Inventory chezmoi-managed sources** (if chezmoi present):
   - `~/git/dotfiles/home/dot_claude/skills/` — what should be materialized
   - Reconcile with #3
5. **Inventory agents**:
   - Plugin-managed: `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/agents/`
   - Personal: `~/.claude/agents/` (if exists)
   - Source: `~/git/dotfiles/plugins/<plugin>/agents/`
6. **Cross-reference with charter** (`~/.claude/CLAUDE.md`):
   - Every agent in charter table should have a definition file
   - Every consult trigger should map to an existing agent
7. **Cross-reference with vault references** (`_AI-index.md`, MEMORY.md):
   - Every `/<skill>` mentioned should resolve to an installed skill
8. **Optional: third-party comparison** — if user supplies a repo (e.g. Jose's dotfiles, obra/superpowers), diff their skill list against personal.
9. **Generate report** using template below.
10. **Present recommendations** for install/skip/remove/restore. Do NOT auto-execute.

## Analysis Categories

### Duplicates / Overlap
- Same name in personal + plugin (e.g. personal `tdd` + `superpowers:test-driven-development`)
- Plugin description significantly overlaps another plugin

### Gaps
- Charter mentions agent but no file exists
- Vault index mentions `/skill` but skill not installed
- Marketplace plugins covering current pain points (claude-md-management, remember, feature-dev) not installed

### Broken State
- Symlinks at `~/.claude/skills/` with missing targets
- Plugins listed in `enabledPlugins` but not in `installed_plugins.json`
- Marketplaces referenced by plugins but not in `known_marketplaces.json`

### Third-Party Picks (when comparison repo given)
- Skills present in third-party but not personal
- Skills with overlap (rank: keep personal / migrate / skip)
- Skills uniquely valuable (no overlap → recommend install)

## Output Format

```markdown
# Plugin Audit — <date>

## Installed Plugins
| Plugin | Marketplace | Version | Enabled | Skills | Agents |
|---|---|---|---|---|---|

## Personal Skills (~/.claude/skills/)
| Skill | Type (file/symlink) | Status | Source |
|---|---|---|---|

## Council Agents (or other agent plugins)
| Agent | Plugin | Charter wired? |
|---|---|---|

## Gaps
- <missing skill referenced in vault>
- <agent in charter without definition>

## Duplicates
- <name>: <where1> vs <where2> → recommendation

## Broken
- <symlink path>: target missing
- <plugin>: enabled but not installed

## Third-Party Comparison (optional)
| Skill | In Personal? | Recommendation |
|---|---|---|

## Recommendations
### Install
- <plugin or skill>: why
### Skip
- <plugin or skill>: why (overlap / niche / not needed)
### Restore / Fix
- <broken thing>: how to fix
### Remove
- <duplicate or stale>: why
```

## Rules

- **Read-only by default.** Never auto-install, auto-remove, or auto-edit. Surface recommendations for user to act on.
- **Cite paths.** Every finding must reference a specific file path or marketplace entry.
- **Don't recommend plugin install just because it exists.** Map every recommendation to a current need (gap in charter, vault reference, pain point in recent sessions).
- **Honor duplicates carefully.** Don't recommend deletion of personal skills until confirming the plugin replacement has equivalent or better content (read both SKILL.md files).
- **Re-run quarterly** or after major plugin marketplace changes — the catalog evolves.
