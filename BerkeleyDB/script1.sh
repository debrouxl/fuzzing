#!/bin/sh
# SPDX-License-Identifier: WTFPL
set -e

cd "${SCRIPTDIR}"

export AFL_PREFIX="${SRCDIR}/AFLplusplus"
export HFUZZ_PREFIX="${SRCDIR}/honggfuzz"

./build_afl.sh
./build_honggfuzz.sh

cd BerkeleyDB
./build_bdb.sh

apt -y install wget openssl db5.3-util

cd "${SRCDIR}"
wget http://archive.debian.org/debian/pool/main/d/db4.2/libdb4.2_4.2.52+dfsg-2_amd64.deb http://archive.debian.org/debian/pool/main/d/db4.2/db4.2-util_4.2.52+dfsg-2_amd64.deb http://archive.debian.org/debian/pool/main/d/db3/libdb3_3.2.9+dfsg-0.1_i386.deb http://archive.debian.org/debian/pool/main/d/db3/libdb3-util_3.2.9+dfsg-0.1_i386.deb http://archive.debian.org/debian/pool/main/d/db2/libdb2_2.7.7.0-9_i386.deb http://archive.debian.org/debian/pool/main/d/db2/libdb2-util_2.7.7.0-9_i386.deb
dpkg --add-architecture i386
apt update
dpkg -i *d*.deb || true
apt -f -y install
dpkg -i -E *d*.deb

mkdir -p input

DB_LOAD="${PREFIX}/bin/db_load" DB_DUMP="${PREFIX}/bin/db_dump" PREFIX="db${VERSION}" "${SCRIPTDIR}/BerkeleyDB/create_dbs.sh" || true
DB_LOAD="db5.3_load"            DB_DUMP="db5.3_dump"            PREFIX="db53"         "${SCRIPTDIR}/BerkeleyDB/create_dbs.sh" || true
DB_LOAD="db4.2_load"            DB_DUMP="db4.2_dump"            PREFIX="db42"         "${SCRIPTDIR}/BerkeleyDB/create_dbs.sh" || true
DB_LOAD="db3_load"              DB_DUMP="db3_dump"              PREFIX="db3"          "${SCRIPTDIR}/BerkeleyDB/create_dbs.sh" || true
DB_LOAD="db_load"               DB_DUMP="db_dump"               PREFIX="db2"          "${SCRIPTDIR}/BerkeleyDB/create_dbs.sh" || true

mkdir -p "${FUZZDIR}/input"
cp input/* "${FUZZDIR}/input/"
