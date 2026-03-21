#!/bin/bash

sketchybar --add item docker right \
           --set docker update_freq=5 \
                        script="$PLUGIN_DIR/docker.sh" \
           --subscribe docker system_woke
