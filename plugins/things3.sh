#!/bin/bash

THINGS="/opt/homebrew/bin/things"
JQ="/opt/homebrew/bin/jq"

TIMER_FILE="/tmp/sbar_things3_timer"
PAUSED_FILE="/tmp/sbar_things3_paused"
UUID_FILE="/tmp/sbar_things3_uuid"
TITLE_FILE="/tmp/sbar_things3_title"
CHECK_FILE="/tmp/sbar_things3_check"

# ── Read persisted state ────────────────────────────────────────────────────
TIMER_START=$(cat "$TIMER_FILE" 2>/dev/null); TIMER_START=${TIMER_START:-0}
PAUSED=$(cat "$PAUSED_FILE"    2>/dev/null); PAUSED=${PAUSED:-0}

CURRENT_UUID=$(cat "$UUID_FILE"   2>/dev/null || echo "")
CURRENT_TITLE=$(cat "$TITLE_FILE" 2>/dev/null || echo "")
LAST_CHECK=$(cat "$CHECK_FILE"    2>/dev/null)
LAST_CHECK=${LAST_CHECK:-0}

NOW=$(date +%s)

# ── Re-query Things3 every 5 min (or on first run) ─────────────────────────
if [ -z "$CURRENT_UUID" ] || [ $((NOW - LAST_CHECK)) -ge 300 ]; then
  ROW=$("$THINGS" today --format json --limit 1 2>/dev/null)

  NEW_UUID=$(echo  "$ROW" | "$JQ" -r '.[0].uuid  // empty')
  NEW_TITLE=$(echo "$ROW" | "$JQ" -r '.[0].title // empty')

  echo "$NOW" > "$CHECK_FILE"

  if [ "$NEW_UUID" != "$CURRENT_UUID" ]; then
    # Todo changed (completed/cancelled) or first run — reset timer
    echo "0" > "$TIMER_FILE"
    echo "0" > "$PAUSED_FILE"
    TIMER_START=0; PAUSED=0
    printf '%s' "$NEW_UUID"  > "$UUID_FILE"
    printf '%s' "$NEW_TITLE" > "$TITLE_FILE"
    CURRENT_UUID="$NEW_UUID"
    CURRENT_TITLE="$NEW_TITLE"
  fi
fi

# ── Nothing to show ─────────────────────────────────────────────────────────
if [ -z "$CURRENT_UUID" ]; then
  sketchybar --set "$NAME" icon="󰄱" label="No todos today"
  exit 0
fi

# ── Truncate long titles ─────────────────────────────────────────────────────
MAX=38
if [ ${#CURRENT_TITLE} -gt $MAX ]; then
  DISPLAY="${CURRENT_TITLE:0:$MAX}…"
else
  DISPLAY="$CURRENT_TITLE"
fi

# ── Render ───────────────────────────────────────────────────────────────────
if [ "$TIMER_START" -gt 0 ]; then
  ELAPSED=$((NOW - TIMER_START))
  REMAINING=$((1200 - ELAPSED))

  if [ "$REMAINING" -le 0 ]; then
    sketchybar --set "$NAME" icon="⏰" label="00:00 – $DISPLAY"
  else
    MINS=$((REMAINING / 60))
    SECS=$((REMAINING % 60))
    sketchybar --set "$NAME" icon="⏱" \
      label="$(printf '%02d:%02d' $MINS $SECS) – $DISPLAY"
  fi
elif [ "$PAUSED" -gt 0 ]; then
  MINS=$((PAUSED / 60))
  SECS=$((PAUSED % 60))
  sketchybar --set "$NAME" icon="⏸" \
    label="$(printf '%02d:%02d' $MINS $SECS) – $DISPLAY"
else
  sketchybar --set "$NAME" icon="󰄱" label="$DISPLAY"
fi
