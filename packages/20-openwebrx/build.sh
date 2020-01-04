#!/usr/bin/env bash
set -euo pipefail

git clone --depth 1 https://github.com/jketterl/openwebrx.git
pushd openwebrx
if [[ ! -z ${BUILD_NUMBER:-} ]]; then
  GBP_ARGS="--debian-branch=develop --snapshot --auto --snapshot-number=${BUILD_NUMBER}"
  gbp dch ${GBP_ARGS}
fi
debuild -us -uc
popd