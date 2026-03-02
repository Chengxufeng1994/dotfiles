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

COST_FMT=$(printf '$%.2f' "$COST")
DURATION_SEC=$((DURATION_MS / 1000))
MINS=$((DURATION_SEC / 60))
SECS=$((DURATION_SEC % 60))

# Git branch (skip optional lock to avoid blocking)
if git rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null)
  STAGED=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
  MODIFIED=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')

  [ "$STAGED" -gt 0 ] && GIT_STATUS="${GREEN}+${STAGED}${RESET}"
  [ "$MODIFIED" -gt 0 ] && GIT_STATUS="${GIT_STATUS}${YELLOW}~${MODIFIED}${RESET}"
fi

DISPLAY="${CYAN}[$MODEL]${RESET} 📁 ${DIR##*/}"
if [ -n "$BRANCH" ]; then
  DISPLAY+=" | 🌿 $BRANCH $GIT_STATUS"
fi

DISPLAY+=" | ${BAR_COLOR}${BAR}${RESET} ${PCT}%"
DISPLAY+=" | ${YELLOW}${COST_FMT}${RESET} | ⏱️ ${MINS}m ${SECS}s"
DISPLAY+=" | ${LIGHT_GREY}${DATETIME}${RESET}"

echo -e "$DISPLAY"
