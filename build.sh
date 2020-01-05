#!/usr/bin/env bash
set -euo pipefail

SRC=$(realpath packages)
CONTAINER_NAME=package-builder
ARCH=$(uname -m)

if [[ ! -z "${SIGN_KEY_FILE:-}" ]]; then
    SIGN_KEY=$(cat "$SIGN_KEY_FILE")
fi

BUILD_NUMBER_ARG=""
if [[ ! -z "${BUILD_NUMBER:-}" ]]; then
    BUILD_NUMBER_ARG="-e BUILD_NUMBER=${BUILD_NUMBER}"
fi

for DIST in `cat dists/$ARCH`; do
    TAG=${DIST//[:]/_}

    docker build --pull --build-arg BASE=$DIST -f docker/Dockerfile-debian -t package-builder:${TAG}_latest .
    RC=0
    docker run --name package-builder -e SIGN_KEY_ID="${SIGN_KEY_ID}" -e SIGN_KEY="$SIGN_KEY" ${BUILD_NUMBER_ARG} package-builder:${TAG}_latest $@ || RC=$?
    if [[ ${RC} ]]; then
        docker cp ${CONTAINER_NAME}:/packages.tar.gz . || RC=$?
    fi
    docker rm ${CONTAINER_NAME}
    if [[ ! ${RC} ]]; then
        exit ${RC}
    fi
    mkdir -p output/${ARCH}/${TAG}
    tar xvfz packages.tar.gz -C output/${ARCH}/${TAG}
    rm packages.tar.gz
done
