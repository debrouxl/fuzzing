#!/bin/sh
# SPDX-License-Identifier: WTFPL
set -e

# This script should be called from the subfolders' scripts, not directly.

# Tested on Debian 10, other recent Debian derivatives do the job as well.
apt update
apt -y full-upgrade
apt -y install --no-install-recommends build-essential llvm-dev clang git ca-certificates libunwind-dev binutils-dev

cd "${SRCDIR}"
git clone --depth=1 https://github.com/google/honggfuzz
cd honggfuzz
make
cd ..
