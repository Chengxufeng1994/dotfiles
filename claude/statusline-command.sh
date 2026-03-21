#!/usr/bin/env bash
# Claude Code status line — mirrors p10k classic style
# Reads JSON from stdin

input=$(cat)

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
ORANGE='\033[38;2;255;140;0m'
CYAN='\033[36m'
LIGHT_GREY='\033[38;5;250m'
RESET='\033[0m'

MODEL=$(echo "$input" | jq -r '.model.display_name')
AGENT_NAME=$(echo "$input" | jq -r '.agent.name // empty')
PROJECT_DIR=$(echo "$input" | jq -r '.workspace.project_dir // .workspace.current_dir' | sed "s|$HOME|~|g")
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
elif [ "$PCT" -ge 80 ]; then
  BAR_COLOR="$ORANGE"
elif [ "$PCT" -ge 70 ]; then
  BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

# Build progress bar: ▕██████░░░░▏
BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR="▕"
for ((i = 0; i < FILLED; i++)); do BAR="${BAR}█"; done
for ((i = 0; i < EMPTY; i++)); do BAR="${BAR}░"; done
BAR="${BAR}▏"

# Update daily cost cache: {date: {session_id: cost}}
SESSION_ID=$(echo "$input" | jq -r '.session_id // "default"')
TODAY=$(date '+%Y-%m-%d')
COST_CACHE="${HOME}/.claude/daily-cost-cache.json"
[ -f "$COST_CACHE" ] || echo '{}' >"$COST_CACHE"
DAILY_COST=$(jq -r --arg date "$TODAY" --arg sid "$SESSION_ID" --arg cost "$COST" \
  '. as $root |
   ($root[$date] // {}) + {($sid): ($cost | tonumber)} as $updated |
   ($root + {($date): $updated}) |
   ((.[$date] // {}) | to_entries | map(.value) | add // 0)' "$COST_CACHE")
jq --arg date "$TODAY" --arg sid "$SESSION_ID" --arg cost "$COST" \
  '.[$date] = ((.[$date] // {}) + {($sid): ($cost | tonumber)})' \
  "$COST_CACHE" >"${COST_CACHE}.tmp" && mv "${COST_CACHE}.tmp" "$COST_CACHE"
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

# Rate limits (Pro/Max only; absent before first API response)
FIVE_H_PCT=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
FIVE_H_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
SEVEN_D_PCT=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

_rl_bar() {
  local pct=$1 width=6
  local filled=$(( pct * width / 100 ))
  local empty=$(( width - filled ))
  local bar="▕"
  for ((i=0; i<filled; i++)); do bar+="█"; done
  for ((i=0; i<empty; i++)); do bar+="░"; done
  bar+="▏"
  echo "$bar"
}

RATE_DISPLAY=""
if [ -n "$FIVE_H_PCT" ]; then
  FIVE_H_INT=$(printf '%.0f' "$FIVE_H_PCT")
  if [ "$FIVE_H_INT" -ge 90 ]; then RL5_COLOR="$RED"
  elif [ "$FIVE_H_INT" -ge 70 ]; then RL5_COLOR="$YELLOW"
  else RL5_COLOR="$GREEN"; fi

  ELAPSED_STR="5h"
  if [ -n "$FIVE_H_RESET" ]; then
    SECS_LEFT=$((FIVE_H_RESET - $(date +%s)))
    if [ "$SECS_LEFT" -gt 0 ]; then
      ELAPSED_SECS=$((18000 - SECS_LEFT))
      ELAPSED_H=$((ELAPSED_SECS / 3600))
      ELAPSED_M=$(((ELAPSED_SECS % 3600) / 60))
      [ "$ELAPSED_H" -gt 0 ] && ELAPSED_STR="${ELAPSED_H}h${ELAPSED_M}m / 5h" || ELAPSED_STR="${ELAPSED_M}m / 5h"
    else
      ELAPSED_STR="5h / 5h"
    fi
  fi
  RL5_BAR=$(_rl_bar "$FIVE_H_INT")
  RATE_DISPLAY="🔋 ${RL5_COLOR}${RL5_BAR}${RESET} ${ELAPSED_STR} (${FIVE_H_INT}%)"

  if [ -n "$SEVEN_D_PCT" ]; then
    SEVEN_D_INT=$(printf '%.0f' "$SEVEN_D_PCT")
    if [ "$SEVEN_D_INT" -ge 90 ]; then RL7_COLOR="$RED"
    elif [ "$SEVEN_D_INT" -ge 70 ]; then RL7_COLOR="$YELLOW"
    else RL7_COLOR="$GREEN"; fi
    RATE_DISPLAY+=" | 7d: ${RL7_COLOR}${SEVEN_D_INT}%${RESET}"
  fi
fi

# Git branch (skip optional lock to avoid blocking)
if git rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null)
  STAGED=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
  MODIFIED=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')

  [ "$STAGED" -gt 0 ] && GIT_STATUS="${GREEN}+${STAGED}${RESET}"
  [ "$MODIFIED" -gt 0 ] && GIT_STATUS="${GIT_STATUS}${YELLOW}~${MODIFIED}${RESET}"
fi

# Line 1: model, agent (if any), project path, git branch, datetime
LINE1="🤖 ${CYAN}${MODEL}${RESET}"
[ -n "$AGENT_NAME" ] && LINE1+=" | 🦾 ${YELLOW}${AGENT_NAME}${RESET}"
LINE1+=" | 📁 $PROJECT_DIR"
[ -n "$BRANCH" ] && LINE1+=" | 🌿 $BRANCH $GIT_STATUS"
LINE1+=" | ${LIGHT_GREY}${DATETIME}${RESET}"

# Line 2: context bar, rate limit, duration, burn rate, datetime
CTX_WARN=""
[ "$PCT" -ge 90 ] && CTX_WARN=" ⚠️"
LINE2="🧠 ${BAR_COLOR}${BAR}${RESET} ${TOKENS_K}k/${WINDOW_K}k (${PCT}%)${CTX_WARN}"
[ -n "$RATE_DISPLAY" ] && LINE2+=" | ${RATE_DISPLAY}"
LINE2+=" | ⏱️ ${MINS}m ${SECS}s"
LINE2+=" | 🔥 ${BURN_COLOR}\$${BURN_RATE}/hr${RESET}"

# Line 3: agent status (only when running as subagent)
OUTPUT="${LINE1}\n${LINE2}"
if [ -n "$AGENT_NAME" ]; then
  TRANSCRIPT=$(echo "$input" | jq -r '.transcript_path // empty')
  LAST_ACTION=""
  if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
    LAST_ACTION=$(tail -n 50 "$TRANSCRIPT" | jq -rsc '
      [.[] | select(.type == "assistant")] | last? |
      [.message.content[]? | select(.type == "text") | .text] | first // ""
    ' 2>/dev/null | tr '\n' ' ' | sed 's/  */ /g' | cut -c1-40)
    [ -n "$LAST_ACTION" ] && LAST_ACTION="${LAST_ACTION}..."
  fi
  LINE3="◐ ${AGENT_NAME} [${MODEL}]"
  [ -n "$LAST_ACTION" ] && LINE3+=": ${LAST_ACTION}"
  OUTPUT+="\n${LIGHT_GREY}${LINE3}${RESET}"
fi
echo -e "$OUTPUT"
