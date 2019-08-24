#!/bin/sh
# SPDX-License-Identifier: WTFPL
set -e

apt update
apt -y install debootstrap qemu-user-static
export CHROOT_DIR="/chroots/debian_mips"
mkdir -p "${CHROOT_DIR}/usr/bin"
cd "${CHROOT_DIR}"
cp /usr/bin/qemu-mips-static usr/bin
debootstrap --arch=mips --variant=minbase --include=db5.3-util,wget,dpkg-dev,openssl,build-essential,autoconf buster .
mkdir -p scripts/BerkeleyDB
cp "${SCRIPTDIR}/BerkeleyDB/create_dbs.sh" "${SCRIPTDIR}/BerkeleyDB/build_bdb.sh" "${SCRIPTDIR}/BerkeleyDB/script2c.sh" scripts/BerkeleyDB/
cp "${SRCDIR}/${TARBALL}" ./
chroot . /scripts/BerkeleyDB/script2c.sh
mkdir -p "${FUZZDIR}/input"
cp input/* "${FUZZDIR}/input/"
