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
DATETIME=$(date +"%Y%m%d-%H%M%S")

# filenames
SRC_DUMP_FILE=${DUMP_FS}/src-${SRC_DBHOST}-${DATETIME}.sql
DST_DUMP_FILE=${DUMP_FS}/dst-${DST_DBHOST}-${DATETIME}.sql
RESTORE_FILE=${DUMP_FS}/restore.sql.$$

#
# dump source data
#
echo "Dumping source dataset (${SRC_DBNAME} @ ${SRC_DBHOST})"
${DUMP_TOOL} -h ${SRC_DBHOST} -P ${SRC_DBPORT} -u ${SRC_DBUSER} ${SRC_DBPASSWD_OPT} ${DUMP_OPTIONS} ${SRC_DBNAME} > ${SRC_DUMP_FILE}
exit_on_error $? "Dump source dataset failed with error $?"

#
# preserve destination data in case of an error
#
echo "Preserving destination dataset (${DST_DBNAME} @ ${DST_DBHOST})"
${DUMP_TOOL} -h ${DST_DBHOST} -P ${DST_DBPORT} -u ${DST_DBUSER} ${DST_DBPASSWD_OPT} ${DUMP_OPTIONS} ${DST_DBNAME} > ${DST_DUMP_FILE}
exit_on_error $? "Dump destination dataset failed with error $?"

#
# rewrites, not used ATM
#
#echo "Applying necessary rewrites..."
cp ${SRC_DUMP_FILE} ${RESTORE_FILE}
exit_on_error $? "Rewrite failed with error $?"

#
# restore the source to the destination
#
echo "Restoring dataset (${DST_DBNAME} @ ${DST_DBHOST})"
${RESTORE_TOOL} -h ${DST_DBHOST} -P ${DST_DBPORT} -u ${DST_DBUSER} ${DST_DBPASSWD_OPT} ${DST_DBNAME} < ${RESTORE_FILE}
exit_on_error $? "Restore dataset failed with error $?"

# cleanup
#rm -fr ${SRC_DUMP_FILE} // preserve the source dump file
#rm -fr ${DST_DUMP_FILE} // preserve the destination dump file
rm -fr ${RESTORE_FILE}

# all over
exit 0

#
# end of file
#
