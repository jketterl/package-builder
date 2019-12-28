#!/usr/bin/env bash
set -euo pipefail

git clone --depth 1 https://github.com/jketterl/digiham.git
pushd digiham
mkdir build
pushd build
cmake ..
cpack
popd
popd
mv digiham/build/*.deb .