#!/bin/bash

sketchybar --add item battery right \
           --set battery update_freq=120 \
                         script="$PLUGIN_DIR/battery.sh" \
                         background.drawing=on \
                         background.color="$RIGHT_SELECTED_BG" \
                         background.corner_radius=7 \
                         background.height=20 \
                         icon.color="$RIGHT_SELECTED_COLOR" \
                         label.color="$RIGHT_SELECTED_COLOR" \
           --subscribe battery system_woke power_source_change
