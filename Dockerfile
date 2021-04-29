# 1) choose base container
# generally use the most recent tag

# data science notebook
# https://hub.docker.com/repository/docker/ucsdets/datascience-notebook/tags
ARG BASE_CONTAINER=ucsdets/datascience-notebook:2020.2-stable

# scipy/machine learning (tensorflow)
# https://hub.docker.com/repository/docker/ucsdets/scipy-ml-notebook/tags
# ARG BASE_CONTAINER=ucsdets/scipy-ml-notebook:2020.2-stable

FROM $BASE_CONTAINER

LABEL maintainer="UC San Diego ITS/ETS <ets-consult@ucsd.edu>"

# 2) change to root
USER root

# 3) install packages
# Install dependencies
RUN sudo apt-get update
RUN sudo apt-get install wget software-properties-common -y
RUN sudo add-apt-repository ppa:ubuntu-toolchain-r/test
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add -
RUN sudo apt-add-repository "deb http://apt.llvm.org/$(lsb_release -c --short)/ llvm-toolchain-$(lsb_release -c --short)-8 main"
RUN sudo apt-get update

# Additional dependencies for Ubuntu 18.04
RUN sudo apt-get install -y build-essential clang-8 lld-8 g++-7 cmake ninja-build libvulkan1 freeglut3-dev mesa-utils x11-xserver-utils libxrandr-dev python python-pip python-dev python3-dev python3-pip libpng-dev libtiff5-dev libjpeg-dev tzdata sed curl unzip autoconf libtool rsync libxml2-dev git
RUN pip2 install --user setuptools
RUN pip3 install --user -Iv setuptools==47.3.1

# Change default clang version
RUN sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/lib/llvm-8/bin/clang++ 180
RUN sudo update-alternatives --install /usr/bin/clang clang /usr/lib/llvm-8/bin/clang 180

# Download Unreal Engine 4.24
git clone --depth 1 -b carla https://github.com/CarlaUnreal/UnrealEngine.git ~/UnrealEngine_4.26
cd ~/UnrealEngine_4.26

# Build Unreal Engine
./Setup.sh && ./GenerateProjectFiles.sh && make

# Clone the CARLA repository
git clone https://github.com/carla-simulator/carla

# Get the CARLA assets
cd ~/carla
./Update.sh

# Set the environment variable
export UE4_ROOT=~/UnrealEngine_4.26

# make the CARLA client
make PythonAPI

# make the CARLA server
make launch

# 4) change back to notebook user
COPY /run_jupyter.sh /
RUN chmod 755 /run_jupyter.sh
USER $NB_UID

# Override command to disable running jupyter notebook at launch
# CMD ["/bin/bash"]
