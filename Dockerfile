FROM ros:melodic-perception

ENV CERES_VERSION="1.14.0"
# sophus requirement
ENV EIGEN_VERSION="3.3.0"
ENV CATKIN_WS=/root/catkin_ws

      # set up thread number for building
RUN   if [ "x$(nproc)" = "x1" ] ; then export USE_PROC=1 ; \
      else export USE_PROC=$(($(nproc)/2)) ; fi && \
      apt-get update && apt-get install -y \
      cmake \
      libatlas-base-dev \
      libeigen3-dev \
      libgoogle-glog-dev \
      libsuitesparse-dev \
      python-catkin-tools \
      ros-${ROS_DISTRO}-cv-bridge \
      ros-${ROS_DISTRO}-image-transport \
      ros-${ROS_DISTRO}-message-filters \
      ros-${ROS_DISTRO}-tf && \
      rm -rf /var/lib/apt/lists/* && \
      mkdir -p $CATKIN_WS/src/VIW-Fusion/

# 克隆 Sophus 仓库
RUN apt-get update
RUN apt-get install wget
# 安装 libfmt-dev
# RUN apt install libfmt-dev

# 下载并安装 CMake 3.8.0
RUN wget -q https://github.com/Kitware/CMake/releases/download/v3.8.0/cmake-3.8.0-Linux-x86_64.tar.gz \
    && tar -xf cmake-3.8.0-Linux-x86_64.tar.gz \
    && rm cmake-3.8.0-Linux-x86_64.tar.gz \
    && mv cmake-3.8.0-Linux-x86_64 /opt/cmake \
    && ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake

# 克隆 fmt 仓库
RUN git clone https://github.com/fmtlib/fmt.git /fmt
WORKDIR /fmt
RUN mkdir build && cd build && cmake .. && make install


# 清除旧版 Eigen3 相关文件
RUN sudo rm -rf /usr/include/eigen3 \
    /usr/lib/cmake/eigen3 \
    /usr/share/doc/libeigen3-dev \
    /usr/share/pkgconfig/eigen3.pc \
    /var/lib/dpkg/info/libeigen3-dev.list \
    /var/lib/dpkg/info/libeigen3-dev.md5sums


RUN git clone https://gitlab.com/libeigen/eigen.git /Eigen3
WORKDIR /Eigen3
RUN git checkout ${EIGEN_VERSION}
RUN mkdir build && cd build && cmake .. && make install
# 复制 Eigen3 头文件
RUN sudo cp -r /usr/local/include/eigen3/Eigen /usr/local/include


# 克隆 ceres-solver 仓库并切换到指定的标签
RUN git clone https://ceres-solver.googlesource.com/ceres-solver && \
    cd ceres-solver && \
    git checkout tags/${CERES_VERSION}

# 创建并进入 build 目录，进行构建和安装
RUN mkdir ceres-solver/build && \
    cd ceres-solver/build && \
    cmake .. && \
    make -j$(nproc) install

# 清理临时文件和目录
RUN rm -rf /ceres-solver

# 克隆 Sophus 仓库
RUN git clone https://github.com/strasdat/Sophus.git /Sophus
# 下载并安装较新版本的 Eigen3
WORKDIR /Sophus
RUN git checkout a0fe89a323e20c42d3cecb590937eb7a06b8343a
RUN mkdir build && cd build && cmake .. && make install


# Copy VINS-Fusion
COPY ./ $CATKIN_WS/src/VIW-Fusion/
# use the following line if you only have this dockerfile
# RUN git clone https://github.com/HKUST-Aerial-Robotics/VINS-Fusion.git

# Build VINS-Fusion
WORKDIR $CATKIN_WS
ENV TERM xterm
ENV PYTHONIOENCODING UTF-8
RUN catkin config \
      --extend /opt/ros/$ROS_DISTRO \
      --cmake-args \
        -DCMAKE_BUILD_TYPE=Release && \
    catkin build && \
    sed -i '/exec "$@"/i \
            source "/root/catkin_ws/devel/setup.bash"' /ros_entrypoint.sh

