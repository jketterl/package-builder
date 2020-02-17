#!/usr/bin/env bash
set -euo pipefail

git clone --depth 1 https://github.com/jketterl/digiham.git
pushd digiham
if [[ ! -z ${RELEASE_BRANCH:-} ]]; then
    git checkout ${RELEASE_BRANCH}
fi
mkdir build
pushd build
cmake ..
cpack
popd
popd
mv digiham/build/*.deb .