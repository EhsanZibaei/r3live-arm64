docker run -it --rm \
  --env="DISPLAY=$DISPLAY" \
  --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
  --network host \
  -v /home/scanr/scanr_og/r3live-arm64/r3live/:/ros_ws/src/r3live-arm64 \
  ehsz/r3live_bash:latest \
  bash