#!/usr/bin/env bash
set -euo pipefail

if [[ $(uname -m) == "x86_64" ]]; then
    BRANCH_ARG="-b 0.19.1"

    git clone --depth 1 ${BRANCH_ARG} https://github.com/jketterl/openwebrx.git
    pushd openwebrx
    if [[ ! -z ${BUILD_NUMBER:-} ]]; then
        GBP_ARGS="--debian-branch=develop --snapshot --auto --snapshot-number=${BUILD_NUMBER}"
        gbp dch ${GBP_ARGS}
    fi
    debuild -us -uc
    popd
fi
