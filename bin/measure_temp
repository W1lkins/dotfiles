#!/bin/sh
temp=$(vcgencmd measure_temp | awk '{print substr($1,6,2)}')
echo "$temp"
exit "$temp"
