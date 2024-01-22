#! /bin/bash

xhost +local:docker

default_name="wiv-fusion"
container_name=`docker container ls -a | grep $default_name | awk '{print $NF}'`
VINS_FUSION_DIR="/home/roy/softwares/wheel-vins/VIW-Fusion/"
KITTI_DATASET="/home/roy/softwares/wheel-vins/bags/"
rviz -d ../config/vins_rviz_config.rviz
if [ "$container_name" != "" ]; then
  echo "enter exit container: $container_name"
  docker exec -it $container_name bash
else
  echo "create new container: $default_name"
	docker run \
	-e DISPLAY=$DISPLAY \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-e GDK_SCALE \
	-e GDK_DPI_SCALE \
	--net=host \
	--name $default_name \
	-v ${VINS_FUSION_DIR}:/root/catkin_ws/src/VIW-Fusion/ \
	-v ${KITTI_DATASET}:/root/kitti_dataset/ \
	-itd ros:viw-fusion-melodic /bin/bash 
fi

