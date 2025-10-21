# Create docker image from Dockerfile
# docker build -t sysroot_ubuntu18_x86_64:latest -f ./sysroot_ubuntu18_x86_64.Dockerfile .

# Run docker image
# docker run -it sysroot_ubuntu18_x86_64

# Copy needed directories from Docker image
# docker cp <DOCKER IMG ID>:/usr .
# docker cp <DOCKER IMG ID>:/lib .
# docker cp <DOCKER IMG ID>:/lib64 .

# Fix invalid links

# Fix ld-linux-x86-64.so.2 -> /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
# cd lib64/
# sudo rm ./ld-linux-x86-64.so.2
# sudo ln -s ../lib/x86_64-linux-gnu/ld-2.27.so ./ld-linux-x86-64.so.2

# Fix libdl.so -> /lib/x86_64-linux-gnu/libdl.so.2
# cd usr/lib/x86_64-linux-gnu
# sudo rm ./libdl.so
# sudo ln -s ../../../lib/x86_64-linux-gnu/libdl.so.2 ./libdl.so

# Fix libmvec.so -> /lib/x86_64-linux-gnu/libmvec.so.1
# cd usr/lib/x86_64-linux-gnu/
# rm ./libmvec.so
# sudo ln -s ../../../lib/x86_64-linux-gnu/libmvec.so.1 ./libmvec.so

FROM ubuntu:18.04

RUN apt-get update
RUN apt-get -y install \
    build-essential \
    gcc-8 g++-8 \
    libomp-dev

RUN rm -rf /usr/include/c++/7
RUN rm -rf /usr/include/c++/7.5.0
RUN rm -rf /usr/include/x86_64-linux-gnu/c++/7
RUN rm -rf /usr/include/x86_64-linux-gnu/c++/7.5.0

WORKDIR /root


