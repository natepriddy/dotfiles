---
name: obsidian-adr
description: Capture an architectural or technical decision as a structured ADR note in the Obsidian vault, then distil a one-liner into brain/decisions.md. Use when making a significant design choice, choosing between approaches, or when a decision warrants a permanent record with full context and alternatives.
allowed-tools: Bash, Read, Write
---

## Purpose

Create a focused ADR (Architecture Decision Record) note in the vault and optionally distil the outcome into `brain/decisions.md`. More targeted than `/obsidian-summary`'s decision type — invoked specifically when a decision is the primary artefact, not a byproduct of a session.

Use this when:
- Choosing between two or more meaningful approaches
- Making a decision that will be hard to reverse
- Documenting a constraint or tradeoff that future sessions need to know about
- Capturing a decision made in a design conversation before implementation begins

---

## Step 1 — Gather decision context

Run first:
```bash
git branch --show-current 2>/dev/null || echo "no-branch"
git rev-parse --show-toplevel 2>/dev/null || echo "no-repo"
date +"%Y-%m-%d"
```

Ask in one message — infer what you can from context first:

> **Tell me about this decision:**
>
> - **Title:** `<inferred or blank>` — short phrase naming the decision (e.g. "Use PostgreSQL over SQLite")
> - **Context:** What situation or problem forced this decision?
> - **Decision:** What was chosen?
> - **Alternatives:** What else was considered and why rejected?
> - **Consequences:** What does this make easier? Harder? What does it preclude?
>
> Fill in what's missing, or press Enter if the context is already in our conversation.

If the decision is fully described in the current conversation, extract it without asking.

---

## Step 2 — Derive vault path

**Project:** final component of repo root path, or ask if ambiguous.

**Label:** strip branch prefixes (`feature/`, `fix/`, `chore/`). For ADRs, derive from the decision subject, not the branch name.

**Filename:** `<YYYY-MM-DD>-<slugified-title>.md`

**Path:** `$VAULT/AI Sessions/<project>/<label>/<filename>`

Show proposed path and ask only if genuinely ambiguous.

---

## Step 3 — Generate the ADR note

```markdown
---
type: decision
project: <project>
branch: <full branch name>
label: <label>
date: <YYYY-MM-DD>
tags:
  - claude-code
  - <project>
  - adr
status: accepted
---

# Decision: <Title>

## Context
<What situation or problem prompted this decision. Be specific — what constraints existed, what was failing, what was the pressure to decide.>

## Decision
<What was decided, stated plainly. One or two sentences.>

> [!important] Summary
> <One-sentence version for scanning.>

## Reasoning
<Why this option over the alternatives. What evidence or principles tipped the balance.>

## Alternatives Considered

| Option | Why Rejected |
|---|---|
| <alt 1> | <reason> |
| <alt 2> | <reason> |

%%Omit table if no meaningful alternatives were considered%%

## Consequences

**Makes easier:**
- <thing this enables>

**Makes harder or precludes:**
- <tradeoff or constraint introduced>

> [!warning] Trade-offs
> <Known downside worth flagging for future sessions. Omit if none.>

## Related
- [[<related session or spec>]]

%%Context at decision time%%
%%Files involved: %%
%%SDD spec: %%
```

---

## Step 4 — Propose brain/decisions.md entry

Distil the decision to a single line suitable for semantic memory:

> **Proposed brain entry:**
> `- <decision one-liner>` → under section `<heading>`
>
> Add to brain/decisions.md? (y / edit / n)

If approved, use `/brain-update decisions "<entry>"` or apply directly.

The one-liner must be:
- Standalone (readable without the ADR note)
- Specific (not "we decided to use X" — instead "use X for Y because Z")
- Proven or high-confidence (if this is speculative, don't add to brain/ yet)

---

## Step 5 — Confirm before writing

Show the full note. Ask:
> **Ready to write?** `<proposed path>`
>
> (`y` to confirm, `e` to edit, `n` to cancel)

---

## Step 6 — Write to vault

```bash
VAULT="${OBSIDIAN_VAULT:?OBSIDIAN_VAULT is not set — set it in ~/.zshrc.local}"
mkdir -p "$VAULT/AI Sessions/<project>/<label>"
```

Write ADR content to `$VAULT/AI Sessions/<project>/<label>/<date>-<slug>.md`.

If brain/decisions.md entry was approved, apply it via `/brain-update decisions "<entry>"` or write directly.

---

## Step 7 — Confirm success

> ✓ ADR saved to `AI Sessions/<project>/<label>/<filename>`
> ✓ brain/decisions.md updated _(if approved)_
>
> 💡 Link this to related session notes with `[[<this filename>]]` if referenced elsewhere.

---

## Rules

- One ADR per decision. If multiple decisions emerged in a session, create multiple ADRs or use `/obsidian-summary` with type: decision instead.
- Status defaults to `accepted`. Use `superseded` if this decision replaces a prior one (link to the old ADR).
- Never add speculative or unconfirmed decisions to brain/decisions.md — only what was actually decided.
- If the decision is minor (implementation detail, naming choice), it doesn't need an ADR. Use `/obsidian-summary` or just capture it in the session note.
