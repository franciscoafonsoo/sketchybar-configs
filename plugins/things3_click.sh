#!/bin/bash

THINGS="/opt/homebrew/bin/things"
JQ="/opt/homebrew/bin/jq"

TIMER_FILE="/tmp/sbar_things3_timer"
PAUSED_FILE="/tmp/sbar_things3_paused"
UUID_FILE="/tmp/sbar_things3_uuid"
TITLE_FILE="/tmp/sbar_things3_title"
CHECK_FILE="/tmp/sbar_things3_check"

# ── Refresh todo first ───────────────────────────────────────────────────────
CURRENT_UUID=$(cat "$UUID_FILE" 2>/dev/null || echo "")
NOW=$(date +%s)
ROW=$("$THINGS" today --format json --limit 1 2>/dev/null)
NEW_UUID=$(echo  "$ROW" | "$JQ" -r '.[0].uuid  // empty')
NEW_TITLE=$(echo "$ROW" | "$JQ" -r '.[0].title // empty')
echo "$NOW" > "$CHECK_FILE"

if [ "$NEW_UUID" != "$CURRENT_UUID" ]; then
  echo "0" > "$TIMER_FILE"
  echo "0" > "$PAUSED_FILE"
  printf '%s' "$NEW_UUID"  > "$UUID_FILE"
  printf '%s' "$NEW_TITLE" > "$TITLE_FILE"
fi

# ── Read (possibly just-reset) timer state ───────────────────────────────────
TIMER_START=$(cat "$TIMER_FILE" 2>/dev/null); TIMER_START=${TIMER_START:-0}
PAUSED=$(cat "$PAUSED_FILE"    2>/dev/null); PAUSED=${PAUSED:-0}

if [ "$BUTTON" = "left" ]; then
  # Left click — open Things3 Today
  open "things:///show?id=today"

elif [ "$BUTTON" = "other" ]; then
  # Middle click — clear timer
  echo "0" > "$TIMER_FILE"
  echo "0" > "$PAUSED_FILE"

elif [ "$TIMER_START" -gt 0 ]; then
  # Right click, Running → Pause: save remaining seconds
  NOW=$(date +%s)
  ELAPSED=$((NOW - TIMER_START))
  REMAINING=$((1200 - ELAPSED))
  [ "$REMAINING" -lt 0 ] && REMAINING=0
  echo "$REMAINING" > "$PAUSED_FILE"
  echo "0" > "$TIMER_FILE"

elif [ "$PAUSED" -gt 0 ]; then
  # Right click, Paused → Resume: reconstruct a synthetic start time
  NOW=$(date +%s)
  echo $((NOW - (1200 - PAUSED))) > "$TIMER_FILE"
  echo "0" > "$PAUSED_FILE"

else
  # Right click, Idle → Start
  date +%s > "$TIMER_FILE"
  echo "0" > "$PAUSED_FILE"
fi
