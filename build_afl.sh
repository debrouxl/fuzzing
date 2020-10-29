#!/bin/sh
# SPDX-License-Identifier: WTFPL
set -e

# This script should be called from the subfolders' scripts, not directly.

# Tested on Debian 10, other recent Debian derivatives do the job as well.
apt update
apt -y full-upgrade
apt -y install --no-install-recommends build-essential llvm-dev clang git ca-certificates file

cd "${SRCDIR}"
git clone --depth=1 https://github.com/vanhauser-thc/AFLplusplus || true
cd AFLplusplus
git pull
make
cd llvm_mode
make
cd ../..
