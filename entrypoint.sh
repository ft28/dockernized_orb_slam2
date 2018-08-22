#!/bin/bash

user_id=$(id -u)
group_id=$(id -g)

if [ ${user_id} = "0" ]; then
    exec $@
fi

export HOME=/home/${user_name}

if [ ${group_id} != "0" ]; then
    groupadd -g ${group_id} ${group_name}
fi
useradd --gid ${group_id} --uid ${user_id} -M -d ${HOME} ${user_name}  -s /bin/bash

cd ${HOME}

if [ ! -e ${HOME}/.bashrc_profile ]; then
    echo "#!/bin/bash"       >  ${HOME}/.bash_profile
    echo ". ${HOME}/.bashrc" >> ${HOME}/.bash_profile
fi

if [ ! -e ${HOME}/.bashrc ]; then
    echo "#!/bin/bash" > ${HOME}/.bashrc
    echo "source /opt/ros/kinetic/setup.bash" >> ${HOME}/.bashrc
    echo "export ROS_PACKAGE_PATH=\${ROS_PACKAGE_PATH}:${HOME}/ORB_SLAM2/Examples/ROS" >> ${HOME}/.bashrc
fi

if [ ! -e catkin_ws/src ]; then
    source /opt/ros/kinetic/setup.bash
    mkdir -p catkin_ws/src
    cd catkin_ws/src
    catkin_init_workspace
    cd ..
    catkin_make
    source devel/setup.bash
    rosdep install tf
    # compile ORB_SLAM2 ROS
    cd ${HOME}
    export ROS_PACKAGE_PATH=${ROS_PACKAGE_PATH}:${HOME}/ORB_SLAM2/Examples/ROS
    cp CMakeLists.txt ORB_SLAM2/Examples/ROS/ORB_SLAM2
    cd ORB_SLAM2
    bash ./build_ros.sh
    bash ./build.sh
fi

exec $@
