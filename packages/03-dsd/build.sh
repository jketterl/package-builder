#!/usr/bin/env bash
set -euo pipefail

git clone --depth 1 https://github.com/jketterl/dsd.git
pushd csdr
debuild -us -uc
popd