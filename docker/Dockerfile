FROM ros:noetic-ros-core-focal

ENV DEBIAN_FRONTEND=noninteractive
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    python3-rosdep \
    python3-rosinstall \
    python3-vcstools \
    && rm -rf /var/lib/apt/lists/*

# bootstrap rosdep
RUN rosdep init && \
  rosdep update --rosdistro $ROS_DISTRO

# install ros packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ros-noetic-ros-base=1.5.0-1* \
    && rm -rf /var/lib/apt/lists/*

# r3live stuff
RUN apt-get update && apt-get install -y \
    ros-noetic-cv-bridge ros-noetic-tf ros-noetic-message-filters ros-noetic-image-transport \ 
    ros-noetic-pcl-conversions ros-noetic-pcl-ros ros-noetic-perception ros-noetic-octomap-*

# build tools and libraries
RUN apt-get update && apt-get install -y \
    libgoogle-glog-dev libatlas-base-dev libeigen3-dev cmake \
    curl wget vim build-essential unzip mesa-utils libgl1-mesa-glx \
    libcgal-dev pcl-tools
    
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

# r3live build
WORKDIR /opt/catkin_ws/src

RUN cat /opt/livox_build/ws_livox/devel/setup.sh >> /opt/ros/noetic/setup.bash

RUN    mv /usr/include/flann/ext/lz4.h /usr/include/flann/ext/lz4.h.bak \
    && mv /usr/include/flann/ext/lz4hc.h /usr/include/flann/ext/lz4.h.bak \
    && ln -s /usr/include/lz4.h /usr/include/flann/ext/lz4.h \
    && ln -s /usr/include/lz4hc.h /usr/include/flann/ext/lz4hc.h

COPY . .

RUN /bin/bash -c '. /opt/ros/noetic/setup.bash; cd ../ && catkin_make'

ADD docker/ros-entrypoint.sh /ros-entrypoint.sh

# COPY dataset /opt/catkin_ws/src/

ENTRYPOINT [ "/ros-entrypoint.sh" ]

CMD ["bash"]
