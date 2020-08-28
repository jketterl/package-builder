#!/usr/bin/env bash
set -euo pipefail

BRANCH_ARG="-b 0.3.0"
git clone --depth 1 ${BRANCH_ARG} https://github.com/jketterl/digiham.git
pushd digiham
mkdir build
pushd build
cmake ..
cpack
popd
popd
mv digiham/build/*.deb .
