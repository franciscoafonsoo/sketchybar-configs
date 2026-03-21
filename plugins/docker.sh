#!/bin/sh

# Check if Docker daemon is running
if pgrep -f "com.docker.backend" > /dev/null 2>&1; then
  # Docker is running
  ICON="󰡨"
  sketchybar --set "$NAME" icon="$ICON" drawing=on
else
  # Docker is not running, hide the item
  sketchybar --set "$NAME" drawing=off
fi
