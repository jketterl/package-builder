#!/usr/bin/env bash
set -euo pipefail

git clone --depth 1 https://github.com/szechyjs/mbelib.git
pushd mbelib
debuild -us -uc
popd