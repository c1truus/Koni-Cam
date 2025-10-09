#!/bin/bash
filename="$HOME/Videos/YT/$(date +%Y%m%d_%H%M%S).h264"
remote="main-pc:~/Videos/fromRPI5/"

# Create directory
mkdir -p "$HOME/Videos/YT"

echo "🎥 Starting recording: $(basename "$filename")"
echo "⏹️  Press Ctrl+C to stop recording"
echo ""

# Start timer
start_time=$(date +%s)
echo "⏰ Recording started at: $(date +%H:%M:%S)"

# Function to show elapsed time
show_elapsed_time() {
    local current_time elapsed minutes seconds
    current_time=$(date +%s)
    elapsed=$((current_time - start_time))
    minutes=$((elapsed / 60))
    seconds=$((elapsed % 60))
    printf "\r⏱️  Recording time: %02d:%02d" "$minutes" "$seconds"
}

# Start recording with minimal output and proper signal handling
rpicam-vid -t 0 --width 1080 --height 1600 --framerate 30 --codec h264 \
           -o "$filename" --nopreview --hflip --vflip 2>/dev/null &
rec_pid=$!

# Timer loop
(
    while kill -0 $rec_pid 2>/dev/null; do
        show_elapsed_time
        sleep 1
    done
) &
timer_pid=$!

# Wait for Ctrl+C
cleanup() {
    kill $rec_pid $timer_pid 2>/dev/null
    echo ""
    echo "🛑 Stopping recording..."
    wait $rec_pid 2>/dev/null
}
trap cleanup SIGINT

wait $rec_pid 2>/dev/null
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
if [ ! -f "$filename" ] || [ "$(stat -c%s "$filename" 2>/dev/null)" -lt 1000 ]; then
    echo "❌ Error: File missing or too small"
    exit 1
fi

file_size=$(( $(stat -c%s "$filename") / 1024 / 1024 ))
echo "📊 File size: ${file_size}MB"

# Transfer file with verbose progress
echo "📤 Transferring to remote server..."
echo "🔗 Source: $filename"
echo "🎯 Destination: $remote"

# Remove the -q flag to show normal SCP progress
if scp "$filename" "$remote"; then
    echo ""
    echo "✅ Successfully transferred"
else
    echo ""
    echo "❌ Transfer failed"
    exit 1
fi
