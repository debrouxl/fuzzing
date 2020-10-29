Description
===========
This folder contains scripts for:

* building [Oracle Berkeley DB](https://www.oracle.com/technetwork/database/database-technologies/berkeleydb/index.html), at version *18.1.40* as of October 2020;
* creating an initial corpus of files;
* fuzzing several BDB CLI tools, using AFL++ or Honggfuzz

in a highly automated fashion.

In order to create disposable build environments, currently based on Debian 11 "Bullseye", you can use e.g. Docker as I'm doing, but the scripts aren't really Docker-specific, so you could use another technology if you wish.

It's a result of my (Lionel Debroux) work fuzzing BDB since late **2014**, at first using zzuf, then afl for most runs, and now AFL++, since July 2019.

NOTE: since 6 executables are being fuzzed, these scripts assume that your computer has at least 6 cores, which had better be separate physical cores, for performance reasons.


Procedure for building and fuzzing
==================================
After cloning / downloading a snapshot of this repo:

* [Download BDB](https://www.oracle.com/technetwork/database/database-technologies/berkeleydb/downloads/index.html). Put the downloaded tarball in $HOME or adjust SRCDIR below.

* From the shell from which you'll be launching the following jobs below, in the root directory of a clone / snapshot of this repo (which also contains this file), *preferably as normal user*, **run**:

```
(as normal user)
export JOBS=<the number of cores you want to use for parallel building; if not provided, 6 jobs will be used>
export TARBALL="db-18.1.40.tar.gz"
export VERSION="18140"
export SRCDIR="${HOME}"
export SCRIPTDIR=$(pwd)
export PREFIX="${HOME}/bdb${VERSION}_prefix"
export FUZZDIR="/dev/shm/libdb${VERSION}_fuzz"
mkdir -p "${SRCDIR}/db${VERSION}_AFLplusplus"
mkdir -p "${SRCDIR}/db${VERSION}_honggfuzz"
mkdir -p "${PREFIX}"
mkdir -p "${PREFIX}_afl"
mkdir -p "${PREFIX}_hfuzz"
mkdir -p "${FUZZDIR}"
```

* **Trigger the native build and little-endian input files generation**, on an amd64 host:

```
(as root, keeping the previously set environment variables)
docker run -it --rm -v "${SRCDIR}/${TARBALL}:${SRCDIR}/${TARBALL}:ro" -v "${SRCDIR}/db${VERSION}_AFLplusplus:${SRCDIR}/db${VERSION}_AFLplusplus" -v "${SRCDIR}/db${VERSION}_honggfuzz:${SRCDIR}/db${VERSION}_honggfuzz" -v "${SCRIPTDIR}:${SCRIPTDIR}:ro" -v "${PREFIX}:${PREFIX}" -v "${PREFIX}_afl:${PREFIX}_afl" -v "${PREFIX}_hfuzz:${PREFIX}_hfuzz" -v "${FUZZDIR}:${FUZZDIR}" -e JOBS="${JOBS}" -e TARBALL="${TARBALL}" -e VERSION="${VERSION}" -e SRCDIR="${SRCDIR}" -e SCRIPTDIR="${SCRIPTDIR}" -e PREFIX="${PREFIX}" -e FUZZDIR="${FUZZDIR}" debian:bullseye /bin/sh "${SCRIPTDIR}/BerkeleyDB/script1.sh"
```
or equivalent.

* **Trigger the cross-build and big-endian input files generation** (internally, a Debian mips chroot is built and used through qemu-user-static, that's why you need privileged mode), on an amd64 host:

```
(as root, keeping the previously set environment variables)
apt install binfmt-support
service binfmt-support start
docker run -it --rm --privileged -v "${SRCDIR}/${TARBALL}:${SRCDIR}/${TARBALL}:ro" -v "${SRCDIR}/db${VERSION}_AFLplusplus:${SRCDIR}/db${VERSION}_AFLplusplus" -v "${SRCDIR}/db${VERSION}_honggfuzz:${SRCDIR}/db${VERSION}_honggfuzz" -v "${SCRIPTDIR}:${SCRIPTDIR}:ro" -v "${PREFIX}:${PREFIX}" -v "${PREFIX}_afl:${PREFIX}_afl" -v "${PREFIX}_hfuzz:${PREFIX}_hfuzz" -v "${FUZZDIR}:${FUZZDIR}" -e JOBS="${JOBS}" -e TARBALL="${TARBALL}" -e VERSION="${VERSION}" -e SRCDIR="${SRCDIR}" -e SCRIPTDIR="${SCRIPTDIR}" -e PREFIX="${PREFIX}" -e FUZZDIR="${FUZZDIR}" debian:bullseye /bin/sh "${SCRIPTDIR}/BerkeleyDB/script2.sh"
```
or equivalent.

* **Start fuzzing jobs**. Fuzzing probably shouldn't be done inside a Docker container, due to the fact that the fuzzing runs leave files behind in the work directory, which I set to  /dev/shm, and that is (was ?) small (by default, at least) on Docker.

```shell
(as root, keeping the previously set environment variables)
cpufreq-set -g performance
(you can install e.g. screen or tmux if you wish)
chown -R (your normal user)... "${SRCDIR}/db${VERSION}_AFLplusplus" "${SRCDIR}/db${VERSION}_honggfuzz" "${PREFIX}" "${FUZZDIR}"
```


AFL jobs:
```
(as normal user)
export VERSION="18140"
export PREFIX="${HOME}/bdb${VERSION}_prefix"
export FUZZDIR="/dev/shm/libdb${VERSION}_fuzz"
export WORKDIR="/dev/shm/libdb${VERSION}_fuzz"
mkdir -p "${WORKDIR}"
export AFL_PREFIX="${HOME}/db${VERSION}_AFLplusplus"
screen bash # For instance, then Ctrl-A c before each subsequent line to create a new tab
# You can use session 0 as a control shell for running e.g. afl-plot or afl-whatsup.
# You do want to use a loop with sleep, or a cronjob, for copying snapshots of FUZZDIR to persistent storage !
mkdir "${WORKDIR}/db${VERSION}_verify_1"; cd "${WORKDIR}/db${VERSION}_verify_1"; ${AFL_PREFIX}/afl-fuzz -i ${FUZZDIR}/input -o ${FUZZDIR}/output -m none -S "db${VERSION}_verify_1" -- "${PREFIX}_afl/bin/db_verify" @@
mkdir "${WORKDIR}/db${VERSION}_dump_1"; cd "${WORKDIR}/db${VERSION}_dump_1"; ${AFL_PREFIX}/afl-fuzz -i ${FUZZDIR}/input -o ${FUZZDIR}/output -m none -S "db${VERSION}_dump_1" -- "${PREFIX}_afl/bin/db_dump" -d a -r @@
mkdir "${WORKDIR}/db${VERSION}_stat_1"; cd "${WORKDIR}/db${VERSION}_stat_1"; ${AFL_PREFIX}/afl-fuzz -i ${FUZZDIR}/input -o ${FUZZDIR}/output -m none -S "db${VERSION}_stat_1" -t50+ -- "${PREFIX}_afl/bin/db_stat" -d @@
mkdir "${WORKDIR}/db${VERSION}_upgrade_1"; cd "${WORKDIR}/db${VERSION}_upgrade_1"; ${AFL_PREFIX}/afl-fuzz -i ${FUZZDIR}/input -o ${FUZZDIR}/output -m none -S "db${VERSION}_upgrade_1" -- "${PREFIX}_afl/bin/db_upgrade" @@
mkdir "${WORKDIR}/db${VERSION}_convert_1"; cd "${WORKDIR}/db${VERSION}_convert_1"; ${AFL_PREFIX}/afl-fuzz -i ${FUZZDIR}/input -o ${FUZZDIR}/output -m none -S "db${VERSION}_convert_1" -- "${PREFIX}_afl/bin/db_convert" @@
mkdir "${WORKDIR}/db${VERSION}_tuner_1"; cd "${WORKDIR}/db${VERSION}_tuner_1"; ${AFL_PREFIX}/afl-fuzz -i ${FUZZDIR}/input -o ${FUZZDIR}/output -m none -S "db${VERSION}_tuner_1" -t50+ -- "${PREFIX}_afl/bin/db_tuner" -d @@
```

Honggfuzz jobs:

```
(as normal user)
export VERSION="18140"
export PREFIX="${HOME}/bdb${VERSION}_prefix"
export FUZZDIR="/dev/shm/libdb${VERSION}_fuzz"
export WORKDIR="/dev/shm/libdb${VERSION}_fuzz"
mkdir -p "${WORKDIR}"
export HFUZZ_PREFIX="${HOME}/db${VERSION}_honggfuzz"
screen bash # For instance, then Ctrl-A c before each subsequent line to create a new tab
# You can use session 0 as a control shell for running e.g. afl-plot or afl-whatsup.
# You do want to use a loop with sleep, or a cronjob, for copying snapshots of FUZZDIR to persistent storage !
mkdir "${WORKDIR}/db${VERSION}_verify_1"; cd "${WORKDIR}/db${VERSION}_verify_1"; ${HONGGFUZZ_PREFIX}/honggfuzz -n 1 -r 3 -F 262144 -v -V -i ${FUZZDIR}/input -o ${FUZZDIR}/output -l "db${VERSION}_verify_1.log" -- "${PREFIX}_hfuzz/bin/db_verify" ___FILE___
mkdir "${WORKDIR}/db${VERSION}_dump_1"; cd "${WORKDIR}/db${VERSION}_dump_1"; ${HONGGFUZZ_PREFIX}/honggfuzz -n 1 -r 3 -F 262144 -v -V -i ${FUZZDIR}/input -o ${FUZZDIR}/output -l "db${VERSION}_dump_1.log" -- "${PREFIX}_hfuzz/bin/db_dump" -d a -r ___FILE___
mkdir "${WORKDIR}/db${VERSION}_stat_1"; cd "${WORKDIR}/db${VERSION}_stat_1"; ${HONGGFUZZ_PREFIX}/honggfuzz -n 1 -r 3 -F 262144 -v -V -i ${FUZZDIR}/input -o ${FUZZDIR}/output -l "db${VERSION}_stat_1.log" -- "${PREFIX}_hfuzz/bin/db_stat" -d ___FILE___
mkdir "${WORKDIR}/db${VERSION}_upgrade_1"; cd "${WORKDIR}/db${VERSION}_upgrade_1"; ${HONGGFUZZ_PREFIX}/honggfuzz -n 1 -r 3 -F 262144 -v -V -i ${FUZZDIR}/input -o ${FUZZDIR}/output -l "db${VERSION}_upgrade_1.log" -- "${PREFIX}_hfuzz/bin/db_upgrade" ___FILE___
mkdir "${WORKDIR}/db${VERSION}_convert_1"; cd "${WORKDIR}/db${VERSION}_convert_1"; ${HONGGFUZZ_PREFIX}/honggfuzz -n 1 -r 3 -F 262144 -v -V -i ${FUZZDIR}/input -o ${FUZZDIR}/output -l "db${VERSION}_convert_1.log" -- "${PREFIX}_hfuzz/bin/db_convert" ___FILE___
mkdir "${WORKDIR}/db${VERSION}_tuner_1"; cd "${WORKDIR}/db${VERSION}_tuner_1"; ${HONGGFUZZ_PREFIX}/honggfuzz -n 1 -r 3 -F 262144 -v -V -i ${FUZZDIR}/input -o ${FUZZDIR}/output -l "db${VERSION}_tuner_1.log" -- "${PREFIX}_hfuzz/bin/db_tuner" -d ___FILE___
```


You want to set up periodic, automated mirroring to persistent storage for `${WORKDIR}`, why not under the form of tarballs to reduce the strain on the filesystem: the __db_bl folders are required to reproduce some crashes, and there tend to be _many_ directories in that file tree.


Important notes for reproducing crashes
=======================================
In order to pinpoint issues *reliably*, you'll need to:

* not only **restart from a fresh copy of the file every time**...
* ... but also **run from a current working directory where a _pristine_ copy of the __db_bl file tree** left behind by crashed or aborted instances of that particular CLI front-end **is available**. Not sure whether the absolute path needs to be the same, but that's not hard to do.

**Really**. I mean the above. While spot checking the output of afl, multiple times, I've noticed that some crashes do not reproduce if the __db_bl file tree is not present, and that some crashes disappear after enough repeated runs of the same command... So yes, you do need to restart from scratch for every single testcase.

Oh, but you won't need to reproduce crashes in the first place, because surely, after more than 5 years and a half, dozens of fixes across multiple releases - 50+ CVE IDs fixed (the vast majority of which were full local DoS, CVSSv2 6.9 / CVSSv3 7.0+) - the Berkeley DB code base must have become rock-solid wrt. offline data corruption, as a consequence of my unpaid fuzzing work on my free time and hopefully lots of proactive fuzzing, fixing and hardening work on Oracle's side. I mean, BDB probably no longer is one of those old code bases whose CLI front-ends can usually be crashed by a fuzzer in less than a minute on a '2018 mobile Core i7-powered laptop... right ? RIGHT ?


License
=======
WTFPLv2, as specified by the LICENSE file.
