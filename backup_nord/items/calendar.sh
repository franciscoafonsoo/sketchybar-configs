#!/bin/bash


sketchybar --add item calendar right \
  --set calendar icon=􀧞 \
  update_freq=30 \
  background.drawing=on \
  background.color="$RIGHT_SELECTED_BG" \
  background.corner_radius=7 \
  background.height=20 \
  icon.color="$RIGHT_SELECTED_COLOR" \
  label.color="$RIGHT_SELECTED_COLOR" \
  script="$PLUGIN_DIR/calendar.sh"
