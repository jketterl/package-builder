#!/usr/bin/env bash
set -euo pipefail

git clone --depth 1 https://github.com/jketterl/openwebrx.git
pushd openwebrx
debuild -us -uc
popd