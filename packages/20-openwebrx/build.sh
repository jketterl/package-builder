#!/usr/bin/env bash
set -euo pipefail

if [[ $(uname -m) == "x86_64" ]]; then
    git clone --depth 1 https://github.com/jketterl/openwebrx.git
    if [[ ! -z ${RELEASE_BRANCH:-} ]]; then
        git checkout ${RELEASE_BRANCH}
    fi
    pushd openwebrx
    if [[ ! -z ${BUILD_NUMBER:-} ]]; then
        GBP_ARGS="--debian-branch=develop --snapshot --auto --snapshot-number=${BUILD_NUMBER}"
        gbp dch ${GBP_ARGS}
    fi
    debuild -us -uc
    popd
fi