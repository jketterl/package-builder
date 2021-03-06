#!/usr/bin/env bash
set -euo pipefail

git clone --depth 1 https://github.com/jketterl/dsd.git
pushd dsd
if [[ ! -z ${BUILD_NUMBER:-} ]]; then
  GBP_ARGS="--debian-branch=master --snapshot --auto --snapshot-number=${BUILD_NUMBER}"
  gbp dch ${GBP_ARGS}
fi
debuild -us -uc
popd