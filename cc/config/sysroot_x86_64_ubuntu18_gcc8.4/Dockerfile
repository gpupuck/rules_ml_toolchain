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
RUN rm -rf /usr/lib/gcc/x86_64-linux-gnu/7

# Fix invalid links
WORKDIR /lib64

# Fix /lib64/ld-linux-x86-64.so.2 -> /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
# cd lib64/
# sudo ln -sfn ../lib/x86_64-linux-gnu/ld-2.27.so ./ld-linux-x86-64.so.2
RUN ln -sfn ../lib/x86_64-linux-gnu/ld-2.27.so ./ld-linux-x86-64.so.2

WORKDIR /usr/lib/x86_64-linux-gnu

# /usr/lib/x86_64-linux-gnu/libutil.so -> /lib/x86_64-linux-gnu/libutil.so.1
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libutil.so.1 ./libutil.so
# /usr/lib/x86_64-linux-gnu/libnsl.so -> /lib/x86_64-linux-gnu/libnsl.so.1
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libnsl.so.1 ./libnsl.so
# /usr/lib/x86_64-linux-gnu/libcidn.so -> /lib/x86_64-linux-gnu/libcidn.so.1
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libcidn.so.1 ./libcidn.so
# /usr/lib/x86_64-linux-gnu/libnss_dns.so -> /lib/x86_64-linux-gnu/libnss_dns.so.2
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libnss_dns.so.2 ./libnss_dns.so
# /usr/lib/x86_64-linux-gnu/libnss_hesiod.so -> /lib/x86_64-linux-gnu/libnss_hesiod.so.2
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libnss_hesiod.so.2 ./libnss_hesiod.so
# /usr/lib/x86_64-linux-gnu/librt.so -> /lib/x86_64-linux-gnu/librt.so.1
RUN ln -sfn ../../../lib/x86_64-linux-gnu/librt.so.1 ./librt.so
# /usr/lib/x86_64-linux-gnu/libnss_nisplus.so -> /lib/x86_64-linux-gnu/libnss_nisplus.so.2
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libnss_nisplus.so.2 ./libnss_nisplus.so
# /usr/lib/x86_64-linux-gnu/libcrypt.so -> /lib/x86_64-linux-gnu/libcrypt.so.1
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libcrypt.so.1 ./libcrypt.so
# /usr/lib/x86_64-linux-gnu/libnss_compat.so -> /lib/x86_64-linux-gnu/libnss_compat.so.2
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libnss_compat.so.2 ./libnss_compat.so
# /usr/lib/x86_64-linux-gnu/libBrokenLocale.so -> /lib/x86_64-linux-gnu/libBrokenLocale.so.1
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libBrokenLocale.so.1 ./libBrokenLocale.so
# /usr/lib/x86_64-linux-gnu/libnss_files.so -> /lib/x86_64-linux-gnu/libnss_files.so.2
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libnss_files.so.2 ./libnss_files.so
# /usr/lib/x86_64-linux-gnu/libresolv.so -> /lib/x86_64-linux-gnu/libresolv.so.2
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libresolv.so.2 ./libresolv.so
# /usr/lib/x86_64-linux-gnu/libnss_nis.so -> /lib/x86_64-linux-gnu/libnss_nis.so.2
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libnss_nis.so.2 ./libnss_nis.so
# /usr/lib/x86_64-linux-gnu/libthread_db.so -> /lib/x86_64-linux-gnu/libthread_db.so.1
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libthread_db.so.1 ./libthread_db.so
# /usr/lib/x86_64-linux-gnu/libanl.so -> /lib/x86_64-linux-gnu/libanl.so.1
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libanl.so.1 ./libanl.so
# /usr/lib/x86_64-linux-gnu/libdl.so -> /lib/x86_64-linux-gnu/libdl.so.2
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libdl.so.2 ./libdl.so
# /usr/lib/x86_64-linux-gnu/libmvec.so -> /lib/x86_64-linux-gnu/libmvec.so.1
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libmvec.so.1 ./libmvec.so

WORKDIR /root

# tar cf - sysroot_x86_64_ubuntu18_gcc8.4-X.Y.Z | xz -T8 -c > sysroot_x86_64_ubuntu18_gcc8.4-X.Y.Z.tar.xz
