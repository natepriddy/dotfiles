# Obsidian Integration
Vault: `$OBSIDIAN_VAULT` (or `OBSIDIAN_VAULT` env var)
Memory layers: `brain/` (semantic) · `AI Sessions/` (episodic) · `AI Tasks/` (working)

## Context Markers
- **🧠 — brain marker:** when you Read any file under `<vault>/brain/` in a turn, prepend 🧠 to that response (after project markers like 🤖). Signals to user that semantic memory was consulted.
- Project AGENTS.md / CLAUDE.md markers (e.g., 🤖) still apply and come FIRST.
- Multiple markers chain in the order introduced.
- Obsidian-related skills must use `obsidian-` prefix.

---

