#!/bin/bash

input_file="$1"
output_file="${2:-${input_file%.*}_rotated.mp4}"

if [ -z "$input_file" ] || [ ! -f "$input_file" ]; then
    echo "Usage: $0 input_file [output_file]"
    exit 1
fi

ffmpeg -r 30 -i "$input_file" -vf "transpose=1" -r 30 -c:v libx264 "$output_file"
