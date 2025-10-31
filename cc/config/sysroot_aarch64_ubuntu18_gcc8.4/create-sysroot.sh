#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <version>"
fi

SYSROOT="$(basename "$(pwd)")"
CONTAINER=$(echo "$SYSROOT" | sed -E 's/.*ubuntu([0-9]+).*/u\1sysroot/')

echo "Please enter sysroot version (default: 0.1.0):"
read VERSION
if [ -z "$VERSION" ]; then
    VERSION="0.1.0"
fi

ARCH_NAME=$SYSROOT-$VERSION

# Remove old files and image
rm -rf /tmp/$ARCH_NAME
docker rm -f $CONTAINER
docker rmi -f $ARCH_NAME:latest

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

echo "Creating /tmp/$ARCH_NAME.tar.xz archive..."
XZ_OPT="-T8"
tar -cJf /tmp/$ARCH_NAME.tar.xz -C /tmp/ $ARCH_NAME