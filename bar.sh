#!/bin/bash

# Miasma/Omarchy theme styling
bar=(
  position=top
  height=31
  margin=6
  y_offset=4
  corner_radius="$CORNER_RADIUS"
  border_color="$BORDER_COLOR"
  border_width=2
  blur_radius=20
  color="$BAR_COLOR"
  shadow=on  # comment this one
)

sketchybar --bar "${bar[@]}"
