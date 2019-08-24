#!/bin/sh
# SPDX-License-Identifier: WTFPL
set -e

SRCDIR=/ SCRIPTDIR=/scripts /scripts/BerkeleyDB/build_bdb.sh

mkdir -p input

wget http://archive.debian.org/debian/pool/main/d/db4.2/libdb4.2_4.2.52+dfsg-5_mips.deb http://archive.debian.org/debian/pool/main/d/db4.2/db4.2-util_4.2.52+dfsg-5_mips.deb http://archive.debian.org/debian/pool/main/d/db3/libdb3_3.2.9+dfsg-0.1_mips.deb http://archive.debian.org/debian/pool/main/d/db3/libdb3-util_3.2.9-16_mips.deb http://archive.debian.org/debian/pool/main/d/db2/libdb2_2.7.7.0-9_mips.deb http://archive.debian.org/debian/pool/main/d/db2/libdb2-util_2.7.7.0-9_mips.deb
dpkg -i *db*.deb

DB_LOAD="${PREFIX}/bin/db_load" DB_DUMP="${PREFIX}/bin/db_dump" PREFIX="db${VERSION}be" /scripts/BerkeleyDB/create_dbs.sh || true
DB_LOAD="db5.3_load"            DB_DUMP="db5.3_dump"            PREFIX="db53be"         /scripts/BerkeleyDB/create_dbs.sh || true
DB_LOAD="db4.2_load"            DB_DUMP="db4.2_dump"            PREFIX="db42be"         /scripts/BerkeleyDB/create_dbs.sh || true
DB_LOAD="db3_load"              DB_DUMP="db3_dump"              PREFIX="db3be"          /scripts/BerkeleyDB/create_dbs.sh || true
DB_LOAD="db_load"               DB_DUMP="db_dump"               PREFIX="db2be"          /scripts/BerkeleyDB/create_dbs.sh || true
