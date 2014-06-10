#!/bin/bash

mkdir -p /tmp/hls

on_die () {
    # kill all children
    pkill -KILL -P $$
}

trap 'on_die' TERM

export FFREPORT="file=/tmp/ffmpeg-report.log"

# Useful parameters to change here based on quality of network
# (ethernet vs wifi vs internet)
# are bitrate in bps (-b), frame rate (-f), and keyframe interval (-g)

# I've built ffmpeg without librtmp so it uses an internal implementation that
# is much lower latency

width=960
height=480
frames=15
bitrate=500000
timeout=0
sharp=0
contrast=0
bright=50
sat=0
evcomp=0
exposure=off
autowb=off
rotation=0
effect=whiteboard

/opt/vc/bin/raspivid -n -vs -mm matrix -vf -g 250 \
	-w $width -h $height -fps $frames -b $bitrate \
	-t $timeout -sh $sharp -co $contrast -br $bright \
	-sa $sat -ev $evcomp -ex $exposure -awb $autowb \
	-rot $rotation -ifx $effect -o - \
  | ffmpeg -loglevel quiet -nostats -y \
      -f h264 \
      -i - \
      -c:v copy \
      -map 0:0 \
      -f flv \
      -rtmp_buffer 100 \
      -rtmp_live live \
      rtmp://localhost/rtmp/live &
wait
