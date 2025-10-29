
FROM arm64v8/ubuntu:bionic

RUN apt-get update && apt-get -y install \
    build-essential \
    gcc-8 g++-8 \
    libomp-dev

RUN rm -rf /usr/include/c++/7.5.0
RUN rm -rf /usr/include/c++/7
RUN rm -rf /usr/include/aarch64-linux-gnu/c++/7.5.0
RUN rm -rf /usr/include/aarch64-linux-gnu/c++/7

WORKDIR /root

# Create docker image from Dockerfile
# docker build -t sysroot_aarch64_ubuntu18:latest .

# Run docker image
# docker run -it sysroot_aarch64_ubuntu18

# Copy needed directories from Docker image
# docker cp <DOCKER IMG ID>:/usr .
# docker cp <DOCKER IMG ID>:/lib .
# docker cp <DOCKER IMG ID>:/lib64 .

# tar cf - sysroot_aarch64_ubuntu18_gcc8.4-X.Y.Z | xz -T8 -c > sysroot_aarch64_ubuntu18_gcc8.4-X.Y.Z.tar.xz