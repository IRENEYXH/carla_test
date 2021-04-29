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
RUN sudo apt-add-repository "deb http://apt.llvm.org/$(lsb_release -c --short)/ llvm-toolchain-$(lsb_release -c --short)-9 main"
RUN sudo apt-get update

# Additional dependencies for Ubuntu 18.04
RUN sudo apt-get install -y build-essential clang-9 lld-9 g++-7 cmake ninja-build libvulkan1 freeglut3-dev mesa-utils x11-xserver-utils libxrandr-dev libpng-dev libtiff5-dev libjpeg-dev tzdata sed curl unzip autoconf libtool rsync libxml2-dev git
RUN pip3 install --user -Iv setuptools==47.3.1

# Change default clang version
RUN sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/lib/llvm-9/bin/clang++ 180
RUN sudo update-alternatives --install /usr/bin/clang clang /usr/lib/llvm-9/bin/clang 180

# Install docker
RUN sudo apt-get update
RUN sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN sudo apt-get update
RUN sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# 4) change back to notebook user
COPY /run_jupyter.sh /
RUN chmod 755 /run_jupyter.sh
USER $NB_UID

# Override command to disable running jupyter notebook at launch
# CMD ["/bin/bash"]
