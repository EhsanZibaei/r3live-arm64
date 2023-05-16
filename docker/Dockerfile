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

# ceres solver
WORKDIR /opt/ceres_build

RUN wget -O ceres.zip https://github.com/ceres-solver/ceres-solver/archive/1.14.0.zip \
    && unzip ceres.zip
 
RUN cd ceres-solver-1.14.0 && mkdir ceres-bin && cd ceres-bin \
    && cmake .. && make install -j4

# livox_ros_driver
# not sure if necessary with RealSense LiDAR
WORKDIR /opt/livox_build

RUN wget -O livox.zip https://github.com/Livox-SDK/Livox-SDK/archive/refs/tags/v2.3.0.zip && unzip livox.zip

RUN cd Livox-SDK-2.3.0/build && cmake .. && make && make install

RUN wget -O livox_ros_driver.zip https://github.com/Livox-SDK/livox_ros_driver/archive/refs/tags/v2.6.0.zip && mkdir -p ws_livox/src && unzip livox_ros_driver.zip -d ws_livox/src

RUN /bin/bash -c '. /opt/ros/noetic/setup.bash; cd ws_livox && catkin_make'

# install librealsense2
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE || sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE \
    && add-apt-repository "deb https://librealsense.intel.com/Debian/apt-repo $(lsb_release -cs) main" -u \
    && apt-get update && apt-get install -y --no-install-recommends librealsense2-dkms librealsense2-utils librealsense2-dev librealsense2-dbg ros-noetic-ddynamic-reconfigure librealsense2-udev-rules \
    && rm -rf /var/lib/apt/lists/*

# build and install realsense-ros
RUN mkdir -p /opt/realsense_build/ws_realsense/src

WORKDIR /opt/realsense_build/ws_realsense/src

RUN git clone https://github.com/IntelRealSense/realsense-ros.git && cd realsense-ros \
    && git checkout `git tag | sort -V | grep -P "^2.\d+\.\d+" | tail -1` \
    && cd ..

RUN /bin/bash -c '. /opt/ros/noetic/setup.bash; catkin_init_workspace && cd  .. \
                    && catkin_make clean \
                    && catkin_make -DCATKIN_ENABLE_TESTING=False -DCMAKE_BUILD_TYPE=Release \
                    && catkin_make install'

# docker container will be configured for realsense
RUN cat /opt/realsense_build/ws_realsense/devel/setup.sh >> /opt/ros/noetic/setup.bash

# r3live build
WORKDIR /opt/catkin_ws/src

RUN cat /opt/livox_build/ws_livox/devel/setup.sh >> /opt/ros/noetic/setup.bash

RUN mv /usr/include/flann/ext/lz4.h /usr/include/flann/ext/lz4.h.bak \
    && mv /usr/include/flann/ext/lz4hc.h /usr/include/flann/ext/lz4.h.bak \
    && ln -s /usr/include/lz4.h /usr/include/flann/ext/lz4.h \
    && ln -s /usr/include/lz4hc.h /usr/include/flann/ext/lz4hc.h

COPY . .

RUN /bin/bash -c '. /opt/ros/noetic/setup.bash; cd ../ && catkin_make'

ADD docker/ros-entrypoint.sh /ros-entrypoint.sh

ENTRYPOINT [ "/ros-entrypoint.sh" ]

CMD ["bash"]
