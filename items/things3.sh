#!/bin/bash

sketchybar --add item things3 left \
  --set things3 \
    icon="󰄱" \
    label="…" \
    update_freq=1 \
    script="$PLUGIN_DIR/things3.sh" \
    click_script="$PLUGIN_DIR/things3_click.sh" \
    icon.font="Hack Nerd Font:Regular:14.0" \
    icon.color="$ACCENT_COLOR" \
    label.color="$ACCENT_COLOR" \
    icon.padding_left=4 \
    icon.padding_right=2 \
    label.padding_left=0 \
    label.padding_right=8
