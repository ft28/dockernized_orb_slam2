FROM ubuntu:16.04

RUN  apt-get update && \
     apt-get install -y build-essential ccache cmake gfortran git && \
     apt-get install -y pkg-config ffmpeg wget unzip tmux

# ROS
RUN apt-get update && apt-get install -q -y dirmngr  gnupg2 lsb-release  && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116 && \
    echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list && \
    apt-get update && \
    apt-get install -y ros-kinetic-ros-core && \
    apt-get install -y ros-kinetic-ros-base && \
    apt-get install -y ros-kinetic-rosbash && \
    apt-get install -y ros-kinetic-roscpp && \
    apt-get install -y ros-kinetic-tf && \
    apt-get install -y ros-kinetic-sensor-msgs && \
    apt-get install -y ros-kinetic-image-transport && \
    apt-get install -y ros-kinetic-cv-bridge && \
    apt-get install -y ros-kinetic-vision-opencv && \
    apt-get install -y ros-kinetic-usb-cam && \
    apt-get install -y guvcview  && \
    rosdep init

WORKDIR /opt

# pangolin
RUN apt-get install -y freeglut3-dev libglew-dev python-pip python3-dev python3-pip

RUN pip install --upgrade pip && \
    python -mpip install numpy pyopengl Pillow pybind11 && \
    git clone https://github.com/stevenlovegrove/Pangolin.git && \
    cd Pangolin && \ 
    git submodule init && git submodule update && \
    mkdir build &&\
    cd build && \
    cmake .. && \
    make && \
    make install && \
    ldconfig

RUN chmod u+s /usr/sbin/useradd  && \
    chmod u+s /usr/sbin/groupadd 

COPY entrypoint.sh  /opt/entrypoint.sh
ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["bash"]
