### rpi5 recording script :
```bash
rpicam-vid -t 0 --width 1080 --height 1600 --framerate 30 --codec h264 -o video.h264 --nopreview --rotation 180 --hflip --vflip
```

### turu converting to mp4 script :
```bash
ffmpeg -r 30 -i video.h264 -vf "transpose=2" -r 30 -c:v libx264 video.mp4
```
