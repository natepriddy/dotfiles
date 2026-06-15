#!/usr/bin/env bash
# Claude Code statusLine — two-line rich format

input=$(cat)

cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // "?"')
model=$(printf '%s' "$input" | jq -r '.model.display_name // .model.id // "?"')
used_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
total_tokens=$(printf '%s' "$input" | jq -r '.context_window.total_tokens // empty')
cost_usd=$(printf '%s' "$input" | jq -r '.cost.total_cost_usd // 0')
duration_ms=$(printf '%s' "$input" | jq -r '.cost.total_duration_ms // 0')

cwd_expanded="${cwd/#\~/$HOME}"
dirname="${cwd_expanded##*/}"

CYAN=$'\033[36m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; RESET=$'\033[0m'; DIM=$'\033[90m'

# Context window size label
ctx_label=""
if [[ -n "$total_tokens" && "$total_tokens" =~ ^[0-9]+$ ]]; then
  if (( total_tokens >= 1000000 )); then
    ctx_label="$(( total_tokens / 1000000 ))M context"
  elif (( total_tokens >= 1000 )); then
    ctx_label="$(( total_tokens / 1000 ))K context"
  fi
fi

# Git branch (using cwd so it works regardless of script's working dir)
branch=""
if git_branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd_expanded" symbolic-ref --short HEAD 2>/dev/null); then
  branch="$git_branch"
elif git_branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd_expanded" rev-parse --short HEAD 2>/dev/null); then
  branch="$git_branch"
fi

# ── Line 1: [Model (Xk context)] 📁 dirname | 🌿 branch ──────────────────────
if [[ -n "$ctx_label" ]]; then
  model_part="${CYAN}[$model ($ctx_label)]${RESET}"
else
  model_part="${CYAN}[$model]${RESET}"
fi

if [[ -n "$branch" ]]; then
  branch_part="| 🌿 ${GREEN}${branch}${RESET}"
else
  branch_part=""
fi

echo -e "$model_part 📁 $dirname $branch_part"

# ── Line 2: ██░░ XX% | $cost | ⏱ Xm Xs ──────────────────────────────────────

# Bar color based on context usage
if (( used_pct >= 90 )); then BAR_COLOR="$RED"
elif (( used_pct >= 70 )); then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

filled=$(( used_pct / 10 ))
empty=$(( 10 - filled ))
printf -v fill "%${filled}s"; printf -v pad "%${empty}s"
bar="${BAR_COLOR}${fill// /█}${DIM}${pad// /░}${RESET}"

cost_fmt=$(printf '$%.2f' "$cost_usd")
mins=$(( duration_ms / 60000 ))
secs=$(( (duration_ms % 60000) / 1000 ))

echo -e "$bar ${used_pct}% | ${YELLOW}${cost_fmt}${RESET} | ⏱️  ${mins}m ${secs}s"
