#!/usr/bin/env bash
set -euo pipefail

git clone --depth 1 https://github.com/jketterl/owrx_connector.git
pushd owrx_connector
if [[ ! -z ${RELEASE_BRANCH:-} ]]; then
    git checkout ${RELEASE_BRANCH}
fi
mkdir build
pushd build
cmake ..
cpack
popd
popd
mv owrx_connector/build/*.deb .