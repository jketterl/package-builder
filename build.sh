#!/usr/bin/env bash
set -euo pipefail

SRC=$(realpath packages)
CONTAINER_NAME=package-builder
ARCH=$(uname -m)

if [[ ! -z "$SIGN_KEY_FILE" ]]; then
    SIGN_KEY=$(cat "$SIGN_KEY_FILE")
fi

for DIST in `cat dists/$ARCH`; do
    TAG=${DIST//[:]/_}
    echo $TAG

    docker build --pull --build-arg BASE=$DIST -f docker/Dockerfile-debian -t package-builder:${TAG}_latest .
    docker run --name package-builder -e SIGN_KEY_ID="$SIGN_KEY_ID" -e SIGN_KEY="$SIGN_KEY" package-builder:${TAG}_latest $@
    docker cp $CONTAINER_NAME:/packages.tar.gz .
    docker rm $CONTAINER_NAME
    mkdir -p output/${TAG}
    tar xvfz packages.tar.gz -C output/${TAG}
    rm packages.tar.gz
done
