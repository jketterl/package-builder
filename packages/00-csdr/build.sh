#!/usr/bin/env bash
set -euo pipefail

git clone --depth 1 -b debian https://github.com/jketterl/csdr.git
pushd csdr
if [[ ! -z ${RELEASE_BRANCH:-} ]]; then
    git checkout ${RELEASE_BRANCH}
fi
if [[ ! -z ${BUILD_NUMBER:-} ]]; then
  GBP_ARGS="--debian-branch=debian --snapshot --auto --snapshot-number=${BUILD_NUMBER}"
  gbp dch ${GBP_ARGS}
fi
debuild -us -uc
popd