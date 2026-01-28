#!/bin/bash

default=(
  padding_left=5
  padding_right=5
  # icon.font="CommitMono Nerd Font:Regular:14"
  # label.font="CommitMono Nerd Font:Regular:14"
  icon.font="Hack Nerd Font:Regular:16.0"
  label.font="Hack Nerd Font:Regular:13.0"
  icon.color="$HIGHLIGHT_COLOR"
  label.color="$HIGHLIGHT_COLOR"
  icon.padding_left=4
  icon.padding_right=4
  label.padding_left=4
  label.padding_right=4
  background.color="$TRANSPARENT"
  background.corner_radius=7
  background.height=20
  background.drawing=off
)

sketchybar --default "${default[@]}"

sketchybar --add event aerospace_workspace_change
sketchybar --add event aerospace_mode_change
sketchybar --add event display_volume_change
