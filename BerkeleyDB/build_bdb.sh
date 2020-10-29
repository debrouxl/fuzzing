#!/bin/sh
# SPDX-License-Identifier: WTFPL
set -e

# Tested on Debian 10, other recent Debian derivatives do the job as well.
cd "${SRCDIR}"

tar xvzf "${SRCDIR}/${TARBALL}"
cd db*/build_unix

if [ "x$JOBS" = "x" ]; then
JOBS=6
fi

../dist/configure --enable-o_direct --enable-dbm --with-repmgr-ssl=no --prefix="${PREFIX}"
# BDB 18.1.40: fix up install errors (sigh)
sed -i -e 's/bdb-sql //g' Makefile
sed -i -e 's/gsg_db_server //g' Makefile
make "-j$JOBS"
make install

if [ -f "${AFL_PREFIX}/afl-clang-fast" -a -f "${AFL_PREFIX}/afl-clang-fast++" ]; then
# Build error in the repmgr when using SSL, and I don't need it, so I just disabled it.
make clean
../dist/configure --enable-o_direct --enable-dbm --with-repmgr-ssl=no --prefix="${PREFIX}_afl" CC="${AFL_PREFIX}/afl-clang-fast" CXX="${AFL_PREFIX}/afl-clang-fast++"
# BDB 18.1.40: fix up install errors (sigh)
sed -i -e 's/bdb-sql //g' Makefile
sed -i -e 's/gsg_db_server //g' Makefile
# Use AddressSanitizer to detect more bugs.
AFL_USE_ASAN=1 make "-j$JOBS"
make install
#ln -s "${PREFIX}_afl" "${PREFIX}/afl"
fi
if [ -f "${HFUZZ_PREFIX}/hfuzz_cc/hfuzz-clang" -a -f "${HFUZZ_PREFIX}/hfuzz_cc/hfuzz-clang++" ]; then
# Build for honggfuzz.
make clean
../dist/configure --enable-o_direct --enable-dbm --with-repmgr-ssl=no --prefix="${PREFIX}_hfuzz" CC="${HFUZZ_PREFIX}/hfuzz_cc/hfuzz-clang" CXX="${HFUZZ_PREFIX}/hfuzz_cc/hfuzz-clang++"
# BDB 18.1.40: fix up install errors (sigh)
sed -i -e 's/bdb-sql //g' Makefile
sed -i -e 's/gsg_db_server //g' Makefile
# Use AddressSanitizer to detect more bugs.
HFUZZ_CC_ASAN=1 make "-j$JOBS"
make install
#ln -s "${PREFIX}_hfuzz" "${PREFIX}/hfuzz"
fi
