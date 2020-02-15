#!/bin/bash

# terminate existing
killall -q polybar

# check for existing
while pgrep -x polybar >/dev/null; do sleep 1; done

# launch polybar on each monitor
for mon in $(polybar -m | awk -F: '{print $1}');
    do MONITOR=$mon polybar --config=~/.config/i3bar/polybar-config --reload main-top &
done
