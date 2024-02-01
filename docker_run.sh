#! /bin/bash

default_name="viw-fusion"
container_name=$(docker container ls -a | grep $default_name | awk '{print $NF}') # 提取容器名
VINS_FUSION_DIR="/home/roy/softwares/wheel-vins/VIW-Fusion/"
ORB_DIR="/home/roy/softwares/ORB_SLAM3/"
KITTI_DATASET="/home/roy/softwares/wheel-vins/bags/"

# 配置X11权限
xhost +local:docker

if [ -n "$container_name" ]; then
    # 检查容器是否正在运行
    if [ "$(docker inspect --format='{{.State.Running}}' $container_name)" = "true" ]; then
        echo "Entering running container: $container_name"
        docker exec -it $container_name bash
    else
        echo "Starting stopped container: $container_name"
        docker start $container_name
        docker exec -it $container_name bash
    fi
else
    echo "Creating new container: $default_name"
    docker run -e DISPLAY=$DISPLAY \
                -v /tmp/.X11-unix:/tmp/.X11-unix \
                -e GDK_SCALE \
                -e GDK_DPI_SCALE \
                --net=host \
                --name $default_name \
                -v ${VINS_FUSION_DIR}:/root/catkin_ws/src/VIW-Fusion/ \
                -v ${ORB_DIR}:/root/catkin_ws/src/ORB_SLAM3/ \
                -v ${KITTI_DATASET}:/root/kitti_dataset/ \
                -itd ros:viw-fusion-melodic /bin/bash
fi

# 完成后，为了安全起见，您可能希望撤销对X11的访问权限
# xhost -local:docker
