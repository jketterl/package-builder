#!/usr/bin/env bash
set -euo pipefail

SRC=$(realpath packages)
#SIGN_KEY_ID=EC56CED77C05107E4C416EF8173873AE062F3A10
#SIGN_KEY=$(gpg --armor --export-secret-key $SIGN_KEY_ID)
CONTAINER_NAME=package-builder
ARCH=$(uname -m)

for DIST in `cat dists/$ARCH`; do
    TAG=${DIST//[:]/_}
    echo $TAG

    docker build --pull --build-arg BASE=$DIST -f docker/Dockerfile-debian -t package-builder:${TAG}_latest .
    docker run --name package-builder -v $SRC:/packages:ro -e SIGN_KEY_ID="$SIGN_KEY_ID" -e SIGN_KEY="$SIGN_KEY" package-builder:${TAG}_latest $@
    docker cp $CONTAINER_NAME:/packages.tar.gz .
    docker rm $CONTAINER_NAME
    mkdir -p output/${TAG}
    tar xvfz packages.tar.gz -C output/${TAG}
    rm packages.tar.gz
done
