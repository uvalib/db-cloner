#!/usr/bin/env bash
#
# Runner process to do the mysql DB clone
#

#set -x

# source the common helper
DIR=$(dirname $0)
. $DIR/common.ksh

# ensure the necessary tools exist
DUMP_TOOL=mysqldump
ensure_tool_available ${DUMP_TOOL}
RESTORE_TOOL=mysql
ensure_tool_available ${RESTORE_TOOL}

DUMP_OPTIONS="--flush-privileges --routines"
RESTORE_OPTIONS=""

# validate the source environment
ensure_var_defined "${SRC_DBHOST}" "SRC_DBHOST"
ensure_var_defined "${SRC_DBPORT}" "SRC_DBPORT"
ensure_var_defined "${SRC_DBNAME}" "SRC_DBNAME"
ensure_var_defined "${SRC_DBUSER}" "SRC_DBUSER"

# validate the destination environment
ensure_var_defined "${DST_DBHOST}" "DST_DBHOST"
ensure_var_defined "${DST_DBPORT}" "DST_DBPORT"
ensure_var_defined "${DST_DBNAME}" "DST_DBNAME"
ensure_var_defined "${DST_DBUSER}" "DST_DBUSER"

# validate other environment needs
ensure_var_defined "${DUMP_FS}" "DUMP_FS"

# bit of sanity checking to prevent operator error
if [ "${SRC_DBHOST}" == "${DST_DBHOST}" ]; then
   if [ "${SRC_DBNAME}" == "${DST_DBNAME}" ]; then
      error_and_exit "ERROR: source database cannot be the same as the destination database on the same host"
   fi
fi

# build the source password option
if [ -z "${SRC_DBPASSWD}" ]; then
   SRC_DBPASSWD_OPT=""
else
   SRC_DBPASSWD_OPT="-p${SRC_DBPASSWD}"
fi

# build the destination password option
if [ -z "${DST_DBPASSWD}" ]; then
   DST_DBPASSWD_OPT=""
else
   DST_DBPASSWD_OPT="-p${DST_DBPASSWD}"
fi

# create timestamp
DATETIME=$(date +"%Y-%m-%d-%H-%M-%S")

# filenames
DUMP_FILE=${DUMP_FS}/mysql-dump-${DATETIME}.sql
RESTORE_FILE=${DUMP_FS}/restore.sql.$$

echo "Dumping dataset (${SRC_DBNAME} @ ${SRC_DBHOST})"
${DUMP_TOOL} -h ${SRC_DBHOST} -P ${SRC_DBPORT} -u ${SRC_DBUSER} ${SRC_DBPASSWD_OPT} ${DUMP_OPTIONS} ${SRC_DBNAME} > ${DUMP_FILE}
exit_on_error $? "Dump dataset failed with error $?"

echo "Applying necessary rewrites..."
cp ${DUMP_FILE} ${RESTORE_FILE}
exit_on_error $? "Rewrite failed with error $?"

echo "Restoring dataset (${DST_DBNAME} @ ${DST_DBHOST})"
#${RESTORE_TOOL} -h ${DST_DBHOST} -P ${DST_DBPORT} -u ${DST_DBUSER} ${DST_DBPASSWD_OPT} ${DST_DBNAME} < xxx
exit_on_error $? "Restore dataset failed with error $?"

# cleanup
#rm -fr ${DUMP_FILE} // preserve the dump file
rm -fr ${RESTORE_FILE}

# all over
echo "Terminating successfully"
exit 0

#
# end of file
#
