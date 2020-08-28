#!/usr/bin/env bash
set -euo pipefail

BRANCH_ARG="-b 0.16.0"
git clone --depth 1 ${BRANCH_ARG} https://github.com/jketterl/csdr.git
pushd csdr
if [[ ! -z ${BUILD_NUMBER:-} ]]; then
  GBP_ARGS="--debian-branch=develop --snapshot --auto --snapshot-number=${BUILD_NUMBER}"
  gbp dch ${GBP_ARGS}
fi
debuild -us -uc
popd
