#!/usr/bin/env bash
set -euo pipefail

BRANCH_ARG=""
if [[ ! -z ${RELEASE_BRANCH:-} ]]; then
    BRANCH_ARG="-b ${RELEASE_BRANCH}"
fi
git clone --depth 1 ${BRANCH_ARG} https://github.com/jketterl/digiham.git
pushd digiham
mkdir build
pushd build
cmake ..
cpack
popd
popd
mv digiham/build/*.deb .