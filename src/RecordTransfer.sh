#!/bin/bash

filename="$HOME/Videos/$(date +%Y%m%d_%H%M%S).h264"
remote="MainMachine@IP:~/Videos/path/to/your/choice/"

echo "🎥 Starting recording: $(basename "$filename")"
echo "⏹️  Press Ctrl+C to stop recording"
echo ""

# Start timer
start_time=$(date +%s)
echo "⏰ Recording started at: $(date +%H:%M:%S)"

# Function to show elapsed time
show_elapsed_time() {
    local current_time=$(date +%s)
    local elapsed=$((current_time - start_time))
    local minutes=$((elapsed / 60))
    local seconds=$((elapsed % 60))
    printf "\r⏱️  Recording time: %02d:%02d" $minutes $seconds
}

# Start recording with suppressed logs
rpicam-vid -t 0 --width 1600 --height 1080 --framerate 30 --codec h264 -o "$filename" --nopreview --level 0.0 2>&1 | \
    while IFS= read -r line; do
        # Show only meaningful progress/error messages
        if [[ $line =~ "frames:" ]] || \
           [[ $line =~ "fps:" ]] || \
           [[ $line =~ "size:" ]] || \
           [[ $line =~ "time:" ]] || \
           [[ $line =~ "bitrate:" ]] || \
           [[ $line =~ "ERROR" ]] || \
           [[ $line =~ "WARN" ]] || \
           [[ $line =~ "signal" ]]; then
            echo "📹 $line"
        fi
    done &

rec_pid=$!

# Timer loop in background
timer_pid=""
(
    while kill -0 $rec_pid 2>/dev/null; do
        show_elapsed_time
        sleep 1
    done
) &
timer_pid=$!

# Wait for Ctrl+C
trap 'kill $rec_pid $timer_pid 2>/dev/null; echo ""; echo "🛑 Stopping recording..."; wait $rec_pid' SIGINT

wait $rec_pid
kill $timer_pid 2>/dev/null

# Calculate final duration
end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))

echo ""
echo "✅ Recording saved: $(basename "$filename")"
echo "⏱️  Total duration: ${minutes}m ${seconds}s"

# Verify file
if [ ! -f "$filename" ] || [ $(stat -c%s "$filename") -lt 1000 ]; then
    echo "❌ Error: File missing or too small"
    exit 1
fi

file_size=$(( $(stat -c%s "$filename") / 1024 / 1024 ))
echo "📊 File size: ${file_size}MB"

# Transfer file
echo "📤 Transferring..."
if scp "$filename" "$remote" 2>/dev/null; then
    echo "✅ Successfully transferred"
else
    echo "❌ Transfer failed"
    exit 1
fi
