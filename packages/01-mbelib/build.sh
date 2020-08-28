#!/usr/bin/env bash
set -euo pipefail

git clone --depth 1 https://github.com/szechyjs/mbelib.git
pushd mbelib
git checkout 9a04ed5c78176a9965f3d43f7aa1b1f5330e771f
if [[ ! -z ${BUILD_NUMBER:-} ]]; then
  GBP_ARGS="--debian-branch=master --snapshot --auto --snapshot-number=${BUILD_NUMBER}"
  gbp dch ${GBP_ARGS}
fi
debuild -us -uc
popd
