#!/usr/bin/env bash
# Claude Code status line — mirrors p10k classic style
# Reads JSON from stdin

input=$(cat)

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
CYAN='\033[36m'
LIGHT_GREY='\033[38;5;250m'

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
TOKENS_USED=$(echo "$input" | jq -r '(.context_window.current_usage.input_tokens // 0) + (.context_window.current_usage.cache_creation_input_tokens // 0) + (.context_window.current_usage.cache_read_input_tokens // 0)')
WINDOW_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
TOKENS_K=$(((TOKENS_USED + 500) / 1000))
WINDOW_K=$((WINDOW_SIZE / 1000))
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
DATETIME=$(date '+%Y-%m-%d %H:%M:%S')

# Pick bar color based on context usage
if [ "$PCT" -ge 90 ]; then
  BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then
  BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

# Build progress bar using loop (tr is byte-based and breaks multi-byte UTF-8)
BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
for ((i = 0; i < FILLED; i++)); do BAR="${BAR}▓"; done
for ((i = 0; i < EMPTY; i++)); do BAR="${BAR}░"; done

# Update daily cost cache: {date: {session_id: cost}}
SESSION_ID=$(echo "$input" | jq -r '.session_id // "default"')
TODAY=$(date '+%Y-%m-%d')
COST_CACHE="${HOME}/.claude/daily-cost-cache.json"
[ -f "$COST_CACHE" ] || echo '{}' > "$COST_CACHE"
DAILY_COST=$(jq -r --arg date "$TODAY" --arg sid "$SESSION_ID" --arg cost "$COST" \
  '. as $root |
   ($root[$date] // {}) + {($sid): ($cost | tonumber)} as $updated |
   ($root + {($date): $updated}) |
   ((.[$date] // {}) | to_entries | map(.value) | add // 0)' "$COST_CACHE")
jq --arg date "$TODAY" --arg sid "$SESSION_ID" --arg cost "$COST" \
  '.[$date] = ((.[$date] // {}) + {($sid): ($cost | tonumber)})' \
  "$COST_CACHE" > "${COST_CACHE}.tmp" && mv "${COST_CACHE}.tmp" "$COST_CACHE"
COST_FMT=$(printf '$%.2f' "$COST")
DAILY_COST_FMT=$(printf '$%.2f' "$DAILY_COST")
DURATION_SEC=$((DURATION_MS / 1000))
MINS=$((DURATION_SEC / 60))
SECS=$((DURATION_SEC % 60))

# Burn rate: cost/hr and tokens/min (requires awk for float math)
TOTAL_TOKENS=$(echo "$input" | jq -r '(.context_window.total_input_tokens // 0) + (.context_window.total_output_tokens // 0)')
read BURN_RATE TOKENS_PER_MIN < <(awk -v cost="$COST" -v dur_ms="$DURATION_MS" -v tokens="$TOTAL_TOKENS" 'BEGIN {
  if (dur_ms <= 0) { print "0.00", "0"; exit }
  hrs = dur_ms / 3600000
  mins = dur_ms / 60000
  printf "%.2f %d\n", cost / hrs, tokens / mins
}')

if [ "$TOKENS_PER_MIN" -ge 5000 ] 2>/dev/null; then
  BURN_COLOR="$RED"
elif [ "$TOKENS_PER_MIN" -ge 2000 ] 2>/dev/null; then
  BURN_COLOR="$YELLOW"
else
  BURN_COLOR="$GREEN"
fi

# Git branch (skip optional lock to avoid blocking)
if git rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null)
  STAGED=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
  MODIFIED=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')

  [ "$STAGED" -gt 0 ] && GIT_STATUS="${GREEN}+${STAGED}${RESET}"
  [ "$MODIFIED" -gt 0 ] && GIT_STATUS="${GIT_STATUS}${YELLOW}~${MODIFIED}${RESET}"
fi

DISPLAY="🤖 ${CYAN}[$MODEL]${RESET} | 📁 ${DIR##*/}"
if [ -n "$BRANCH" ]; then
  DISPLAY+=" | 🌿 $BRANCH $GIT_STATUS"
fi

DISPLAY+="\n🧠 ${BAR_COLOR}${BAR}${RESET} ${TOKENS_K}k/${WINDOW_K}k (${PCT}%)"
DISPLAY+=" | 🔥 ${BURN_COLOR}\$${BURN_RATE}/hr${RESET} | 💰 ${YELLOW}${COST_FMT} session${RESET} | 📅 ${YELLOW}${DAILY_COST_FMT} today${RESET} | ⏱️ ${MINS}m ${SECS}s"
DISPLAY+=" | ${LIGHT_GREY}${DATETIME}${RESET}"

echo -e "$DISPLAY"
