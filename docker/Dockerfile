FROM ros:noetic-ros-core-focal

ENV DEBIAN_FRONTEND=noninteractive
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# install bootstrap tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3-rosdep \
    python3-rosinstall \
    python3-vcstools \
    git ripgrep \
    software-properties-common

# bootstrap rosdep
RUN rosdep init && \
  rosdep update --rosdistro $ROS_DISTRO

# install ros packages
RUN apt-get install -y --no-install-recommends \
    ros-noetic-ros-base=1.5.0-1* \
    ros-noetic-cv-bridge ros-noetic-tf ros-noetic-message-filters ros-noetic-image-transport ros-noetic-xacro \
    ros-noetic-pcl-conversions ros-noetic-pcl-ros ros-noetic-perception ros-noetic-octomap-*  \
    ros-noetic-robot-state-publisher ros-noetic-diagnostic-updater ros-noetic-rgbd-launch

# install tools and libraries
RUN apt-get install -y --no-install-recommends \
    libgoogle-glog-dev libatlas-base-dev libeigen3-dev cmake \
    curl wget vim build-essential unzip mesa-utils libgl1-mesa-glx \
    libcgal-dev pcl-tools \
    && rm -rf /var/lib/apt/lists/*

# livox_ros_driver
# not sure if necessary with RealSense LiDAR
WORKDIR /opt/livox_build

RUN wget -O livox.zip https://github.com/Livox-SDK/Livox-SDK/archive/refs/tags/v2.3.0.zip && unzip livox.zip

RUN cd Livox-SDK-2.3.0/build && cmake .. && make && make install

RUN wget -O livox_ros_driver.zip https://github.com/Livox-SDK/livox_ros_driver/archive/refs/tags/v2.6.0.zip && mkdir -p ws_livox/src && unzip livox_ros_driver.zip -d ws_livox/src

RUN /bin/bash -c '. /opt/ros/noetic/setup.bash; cd ws_livox && catkin_make'

# r3live build


WORKDIR /opt/catkin_ws/src

RUN git clone https://github.com/EhsanZibaei/r3live-arm64.git

WORKDIR /opt/catkin_ws

RUN /bin/bash -c "source /opt/livox_build/ws_livox/devel/setup.bash && catkin_make"

CMD ["/bin/bash", "-c", "source /opt/catkin_ws/devel/setup.bash && roslaunch r3live r3live_bag.launch"]
