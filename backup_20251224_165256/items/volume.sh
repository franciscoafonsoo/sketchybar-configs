#!/bin/bash

sketchybar --add item volume right \
  --set volume script="$PLUGIN_DIR/volume.sh" \
  background.drawing=on \
  background.color="$RIGHT_SELECTED_BG" \
  background.corner_radius=7 \
  background.height=20 \
  icon.color="$RIGHT_SELECTED_COLOR" \
  label.color="$RIGHT_SELECTED_COLOR" \
  --subscribe volume volume_change display_volume_change
