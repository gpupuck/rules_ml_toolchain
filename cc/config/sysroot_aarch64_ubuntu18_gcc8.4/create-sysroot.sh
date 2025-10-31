#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage (subscript): $0 <sysroot> <version>"
    exit 1
fi

SYSROOT="$1"
VERSION="$2"

ARCH_NAME=sysroot_aarch64_ubuntu18_gcc8.4-0.2.0

# Remove old files and image
rm -f ./$ARCH_NAME/$ARCH_NAME.tar.xz
rm -rf ./$ARCH_NAME
docker rm -f u18sysroot
docker rmi -f $ARCH_NAME:latest

# Create docker image from Dockerfile
docker build -t $ARCH_NAME:latest .

mkdir ./$ARCH_NAME

# Run docker image
docker run -d --name u18sysroot $ARCH_NAME:latest bash -c "sleep 20"

# Copy needed directories from Docker image
docker cp u18sysroot:/lib ./$ARCH_NAME/
docker cp u18sysroot:/usr ./$ARCH_NAME/
rm -rf ./$ARCH_NAME/lib/cpp
rm -rf ./$ARCH_NAME/usr/bin
rm -rf ./$ARCH_NAME/usr/games
rm -rf ./$ARCH_NAME/usr/sbin
rm -rf ./$ARCH_NAME/usr/share
rm -rf ./$ARCH_NAME/usr/src

echo "Creating $ARCH_NAME.tar.xz archive..."
tar cf - $ARCH_NAME | xz -T8 -c > $ARCH_NAME.tar.xz
