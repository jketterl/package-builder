#!/usr/bin/env bash
set -euo pipefail

git clone --depth 1 https://github.com/jketterl/dsd.git
pushd dsd
git checkout f0fc33ab35cf8b4f8185f69bad4eea42d64d8b70
if [[ ! -z ${BUILD_NUMBER:-} ]]; then
  GBP_ARGS="--debian-branch=master --snapshot --auto --snapshot-number=${BUILD_NUMBER}"
  gbp dch ${GBP_ARGS}
fi
debuild -us -uc
popd