# Create docker image from Dockerfile
# docker build -t sysroot_ubuntu18_x86_64:latest -f .

# Run docker image
# docker run -it sysroot_ubuntu18_x86_64

# Copy needed directories from Docker image
# docker cp <DOCKER IMG ID>:/usr .
# docker cp <DOCKER IMG ID>:/lib .
# docker cp <DOCKER IMG ID>:/lib64 .

FROM ubuntu:18.04

RUN apt-get update
RUN apt-get -y install \
    build-essential \
    gcc-8 g++-8 \
    libomp-dev

RUN rm -rf /usr/include/c++/7.5.0
RUN rm -rf /usr/include/c++/7
RUN rm -rf /usr/include/x86_64-linux-gnu/c++/7.5.0
RUN rm -rf /usr/include/x86_64-linux-gnu/c++/7

# Fix invalid links
WORKDIR /lib64

# Fix /lib64/ld-linux-x86-64.so.2 -> /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
# cd lib64/
# sudo ln -sfn ../lib/x86_64-linux-gnu/ld-2.27.so ./ld-linux-x86-64.so.2
RUN ln -sfn ../lib/x86_64-linux-gnu/ld-2.27.so ./ld-linux-x86-64.so.2

WORKDIR /usr/lib/x86_64-linux-gnu

# Fix /usr/lib/x86_64-linux-gnu/libdl.so -> /lib/x86_64-linux-gnu/libdl.so.2
# cd usr/lib/x86_64-linux-gnu
# sudo ln -sfn ../../../lib/x86_64-linux-gnu/libdl.so.2 ./libdl.so
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libdl.so.2 ./libdl.so

# Fix /usr/lib/x86_64-linux-gnu/libmvec.so -> /lib/x86_64-linux-gnu/libmvec.so.1
# cd usr/lib/x86_64-linux-gnu/
# sudo ln -sfn ../../../lib/x86_64-linux-gnu/libmvec.so.1 ./libmvec.so
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libmvec.so.1 ./libmvec.so

WORKDIR /root

# tar cf - sysroot_x86_64_ubuntu18_gcc8.4-X.Y.Z | xz -T8 -c > sysroot_x86_64_ubuntu18_gcc8.4-X.Y.Z.tar.xz
