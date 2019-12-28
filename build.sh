#!/usr/bin/env bash
set -euo pipefail

docker build --pull --build-arg BASE=debian:buster -f docker/Dockerfile-debian -t package-builder:latest .

SRC=$(realpath packages)
SIGN_KEY_ID=EC56CED77C05107E4C416EF8173873AE062F3A10
SIGN_KEY=$(gpg --armor --export-secret-key $SIGN_KEY_ID)
CONTAINER_NAME=package-builder

docker run --name package-builder -it -v $SRC:/packages:ro -e SIGN_KEY_ID="$SIGN_KEY_ID" -e SIGN_KEY="$SIGN_KEY" package-builder:latest $@
docker cp $CONTAINER_NAME:/packages.tar.gz .
docker rm $CONTAINER_NAME
mkdir -p output
tar xvfz packages.tar.gz -C output
rm packages.tar.gz
