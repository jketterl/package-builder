#!/usr/bin/env bash
set -euo pipefail

git clone --depth 1 -b debian https://github.com/jketterl/csdr.git
pushd csdr
debuild -us -uc
popd