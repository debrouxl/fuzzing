#!/bin/sh
# SPDX-License-Identifier: WTFPL
set -x
echo -e "key\nvalue" | "${DB_LOAD}" -c db_pagesize=512 -T -t hash "input/${PREFIX}_hash512.db"
echo -e "" | "${DB_LOAD}" -c db_pagesize=512 -T -t hash "input/${PREFIX}_hash512_empty.db"
echo -e "key\nvalue" | "${DB_LOAD}" -c db_pagesize=1024 -T -t hash "input/${PREFIX}_hash1024.db"
echo -e "key\nvalue" | "${DB_LOAD}" -c db_pagesize=4096 -T -t hash "input/${PREFIX}_hash4096.db"
echo -e "key\nvalue" | "${DB_LOAD}" -c db_pagesize=512 -T -t btree "input/${PREFIX}_btree512.db"
echo -e "" | "${DB_LOAD}" -c db_pagesize=512 -T -t btree "input/${PREFIX}_btree512_empty.db"
echo -e "line1\nline2" | "${DB_LOAD}" -c db_pagesize=512 -T -t recno "input/${PREFIX}_recno512.db"
echo -e "" | "${DB_LOAD}" -c db_pagesize=512 -T -t recno "input/${PREFIX}_recno512_empty.db"
echo -e "line1\nline2" | "${DB_LOAD}" -c db_pagesize=512 -c re_len=16 -c "re_pad= " -T -t queue "input/${PREFIX}_queue512.db"
echo -ne "" | "${DB_LOAD}" -c db_pagesize=512 -c re_len=4 -c "re_pad= " -T -t queue "input/${PREFIX}_queue512_empty.db"
echo -e "key\nvalue\nkey2\nvalue2" | "${DB_LOAD}" -c db_pagesize=512 -c h_nelem=8 -c duplicates=1 -c dupsort=1 -T -t hash "input/${PREFIX}_hash512_dup.db"
echo -e "key\nvalue\nkey2\nvalue2" | "${DB_LOAD}" -c db_pagesize=512 -c duplicates=1 -c dupsort=1 -T -t btree "input/${PREFIX}_btree512_dup.db"
echo -e "line1\nline2\nline3\nline4" | "${DB_LOAD}" -c db_pagesize=512 -c re_len=16 -c "re_pad= " -T -t recno "input/${PREFIX}_recno512_len.db"
echo -e "line1\nline2\nline3\nline4" | "${DB_LOAD}" -c db_pagesize=512 -c re_len=16 -c "re_pad= " -T -t queue "input/${PREFIX}_queue512_len.db"
echo -e "key\nvalue\nkey2\nvalue2" | "${DB_LOAD}" -c db_pagesize=512 -c chksum=1 -T -t hash "input/${PREFIX}_hash512_chksum.db"
echo -e "key\nvalue\nkey2\nvalue2" | "${DB_LOAD}" -c db_pagesize=512 -c chksum=1 -T -t btree "input/${PREFIX}_btree512_chksum.db"
echo -e "line1\nline2" | "${DB_LOAD}" -c db_pagesize=512 -c chksum=1 -T -t recno "input/${PREFIX}_recno512_chksum.db"
echo -e "line1\nline2" | "${DB_LOAD}" -c db_pagesize=512 -c chksum=1 -c re_len=8 -c "re_pad= " -T -t queue "input/${PREFIX}_queue512_chksum.db"
# Uses an external file, and as such, isn't very suitable for fuzzing with afl without more work.
#echo -e "line1\nline2\nline3\nline4" | "${DB_LOAD}" -c db_pagesize=512 -c extentsize=1 -c re_len=8 -c "re_pad= " -T -t queue "input/${PREFIX}_queue512_extents.db"
echo -e "key\nvalue\nkey2\nvalue2" | "${DB_LOAD}" -c db_pagesize=512 -c bt_minkey=2 -T -t btree "input/${PREFIX}_btree512_minkey.db"
"${DB_DUMP}" -k input/${PREFIX}_recno512_chksum.db | "${DB_LOAD}" -c db_pagesize=512 -c keys=1 -t recno "input/${PREFIX}_recno512_keys.db"
"${DB_DUMP}" -k input/${PREFIX}_queue512_chksum.db | "${DB_LOAD}" -c db_pagesize=512 -c keys=1 -t queue "input/${PREFIX}_queue512_keys.db"

echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512 -c database=test1 -T -t hash "input/${PREFIX}_hash512_db.db"
echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512 -c database=test2 -T -t btree "input/${PREFIX}_btree512_db.db"
echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512 -c database=test3 -T -t recno "input/${PREFIX}_recno512_db.db"
echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512 -c database=test4 -c re_len=8 -c "re_pad= " -T -t recno "input/${PREFIX}_queue512_db.db"

echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512 -c database=test5 -c subdatabase=subdb1 -c h_ffactor=1 -T -t hash "input/${PREFIX}_hash512_subdb.db"
echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512 -c database=test6 -c subdatabase=subdb2 -T -t btree "input/${PREFIX}_btree512_subdb.db"
echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512 -c database=test7 -c subdatabase=subdb3 -T -t recno "input/${PREFIX}_recno512_subdb.db"
# Single DB for queue DBs.
#echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512 -c database=test8 -c subdatabase=subdb4 -c re_len=8 -c "re_pad= " -T -t queue "input/${PREFIX}_queue512_subdb.db"

echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512 -c database=test11 -T -t hash "input/${PREFIX}_hash512_dbs.db"
echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512 -c database=test12 -T -t hash "input/${PREFIX}_hash512_dbs.db"
echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512 -c database=test21 -T -t btree "input/${PREFIX}_btree512_dbs.db"
echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512 -c database=test22 -T -t btree "input/${PREFIX}_btree512_dbs.db"
echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512 -c database=test31 -T -t recno "input/${PREFIX}_recno512_dbs.db"
echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512 -c database=test32 -T -t recno "input/${PREFIX}_recno512_dbs.db"
# Single DB for queue DBs.

echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512 -c database=test11 -c subdatabase=subdb1 -T -t hash "input/${PREFIX}_hash512_dbs_subdbs.db"
echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512 -c database=test11 -c subdatabase=subdb2 -T -t hash "input/${PREFIX}_hash512_dbs_subdbs.db"
echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512 -c database=test12 -c subdatabase=subdb1 -T -t hash "input/${PREFIX}_hash512_dbs_subdbs.db"
echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512 -c database=test12 -c subdatabase=subdb2 -T -t hash "input/${PREFIX}_hash512_dbs_subdbs.db"
echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512 -c database=test21 -c subdatabase=subdb1 -T -t btree "input/${PREFIX}_btree512_dbs_subdbs.db"
echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512 -c database=test21 -c subdatabase=subdb2 -T -t btree "input/${PREFIX}_btree512_dbs_subdbs.db"
echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512 -c database=test22 -c subdatabase=subdb1 -T -t btree "input/${PREFIX}_btree512_dbs_subdbs.db"
echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512 -c database=test22 -c subdatabase=subdb2 -T -t btree "input/${PREFIX}_btree512_dbs_subdbs.db"
echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512 -c database=test31 -c subdatabase=subdb1 -T -t recno "input/${PREFIX}_recno512_dbs_subdbs.db"
echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512 -c database=test31 -c subdatabase=subdb2 -T -t recno "input/${PREFIX}_recno512_dbs_subdbs.db"
echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512 -c database=test32 -c subdatabase=subdb1 -T -t recno "input/${PREFIX}_recno512_dbs_subdbs.db"
echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512 -c database=test32 -c subdatabase=subdb2 -T -t recno "input/${PREFIX}_recno512_dbs_subdbs.db"
# Single DB and no-subDB for queue DBs.
#echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512                    -c subdatabase=subdb1 -c re_len=8 -c "re_pad= " -T -t queue "input/${PREFIX}_queue512_subdbs.db"
#echo -e "`openssl rand 8`\n`openssl rand 8`" | "${DB_LOAD}" -c db_pagesize=512                    -c subdatabase=subdb2 -c re_len=8 -c "re_pad= " -T -t queue "input/${PREFIX}_queue512_subdbs.db"

for i in `seq 1 10`; do
echo -e "$i\n$i" | "${DB_LOAD}" -c db_pagesize=512 -T -t hash "input/${PREFIX}_hash512_10.db" &
echo -e "$i\n$i" | "${DB_LOAD}" -c db_pagesize=512 -c subdatabase="$i" -T -t hash "input/${PREFIX}_hash512_10_subdbs.db" &
echo -e "$i\n$i" | "${DB_LOAD}" -c db_pagesize=512 -T -t btree "input/${PREFIX}_btree512_10.db" &
echo -e "$i\n$i" | "${DB_LOAD}" -c db_pagesize=512 -c subdatabase="$i" -T -t btree "input/${PREFIX}_btree512_10_subdbs.db" &
echo -e "$i\n$i" | "${DB_LOAD}" -c db_pagesize=512 -T -t recno "input/${PREFIX}_recno512_10.db" &
echo -e "$i\n$i" | "${DB_LOAD}" -c db_pagesize=512 -c subdatabase="$i" -T -t recno "input/${PREFIX}_recno512_10_subdbs.db" &
echo -e "$i\n$i" | "${DB_LOAD}" -c db_pagesize=512 -c re_len=32 -c "re_pad= " -T -t queue "input/${PREFIX}_queue512_10.db" &
#echo -e "$i\n$i" | "${DB_LOAD}" -c db_pagesize=512 -c subdatabase="$i" -c re_len=32 -c "re_pad= " -T -t queue "input/${PREFIX}_queue512_10_subdbs.db" &
wait
done

for i in `seq 1 100`; do
echo -e "$i\n$i" | "${DB_LOAD}" -c db_pagesize=512 -T -t hash "input/${PREFIX}_hash512_100.db" &
echo -e "$i\n$i" | "${DB_LOAD}" -c db_pagesize=512 -T -t btree "input/${PREFIX}_btree512_100.db" &
echo -e "$i\n$i" | "${DB_LOAD}" -c db_pagesize=512 -T -t recno "input/${PREFIX}_recno512_100.db" &
echo -e "$i\n$i" | "${DB_LOAD}" -c db_pagesize=512 -c re_len=8 -c "re_pad= " -T -t queue "input/${PREFIX}_queue512_100.db" &
done

wait