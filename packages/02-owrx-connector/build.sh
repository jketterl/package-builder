#!/usr/bin/env bash
set -euo pipefail

BRANCH_ARG="-b 0.2.0"
git clone --depth 1 ${BRANCH_ARG} https://github.com/jketterl/owrx_connector.git
pushd owrx_connector
mkdir build
pushd build
cmake ..
cpack
popd
popd
mv owrx_connector/build/*.deb .
