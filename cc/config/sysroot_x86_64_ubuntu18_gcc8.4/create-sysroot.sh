#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage (subscript): $0 <sysroot> <version>"
    exit 1
fi

SYSROOT="$1"
VERSION="$2"
CONTAINER="$3"
ARCH_NAME=$SYSROOT-$VERSION

# Create docker image from Dockerfile
docker build -t $ARCH_NAME:latest .

# Run docker image
docker run -d --name $CONTAINER $ARCH_NAME:latest bash -c "sleep 20"

mkdir /tmp/$ARCH_NAME

# Copy needed directories from Docker image
docker cp $CONTAINER:/lib /tmp/$ARCH_NAME/
docker cp $CONTAINER:/usr /tmp/$ARCH_NAME/
# Remove not used directories
rm -rf /tmp/$ARCH_NAME/lib/cpp
rm -rf /tmp/$ARCH_NAME/usr/bin
rm -rf /tmp/$ARCH_NAME/usr/games
rm -rf /tmp/$ARCH_NAME/usr/sbin
rm -rf /tmp/$ARCH_NAME/usr/share
rm -rf /tmp/$ARCH_NAME/usr/src

