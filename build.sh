#!/usr/bin/env bash
set -euo pipefail

ARCH=$(uname -m)

for DIST in `cat dists/$ARCH`; do
    TAG=${DIST//[:]/_}_${ARCH}_openwebrx_0.19.1

    docker build --pull --build-arg BASE=$DIST -f docker/Dockerfile-debian -t 768356633999.dkr.ecr.eu-central-1.amazonaws.com/package-builder:${TAG} .
    docker push 768356633999.dkr.ecr.eu-central-1.amazonaws.com/package-builder:${TAG}
done
