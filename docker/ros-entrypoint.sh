#!/bin/bash

set -e

echo "ROS environment setup added by ros-entrypoint.sh"
echo "source /opt/ros/noetic/setup.bash" >> /root/.bashrc
echo "source /opt/catkin_ws/devel/setup.bash" >> /root/.bashrc
exec "$@"
