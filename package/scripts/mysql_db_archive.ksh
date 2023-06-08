#!/usr/bin/env bash
#
# Runner process to do the mysql DB archive
#

#set -x

# source the common helper
DIR=$(dirname $0)
. $DIR/common.ksh

# ensure the necessary tools exist
DUMP_TOOL=mysqldump
ensure_tool_available ${DUMP_TOOL}
COMPRESS_TOOL=gzip
ensure_tool_available ${COMPRESS_TOOL}

DUMP_OPTIONS="--flush-privileges --routines"
RESTORE_OPTIONS=""

# validate the environment
ensure_var_defined "${DBHOST}" "DBHOST"
ensure_var_defined "${DBPORT}" "DBPORT"
ensure_var_defined "${DBNAME}" "DBNAME"
ensure_var_defined "${DBUSER}" "DBUSER"

# validate other environment needs
ensure_var_defined "${DUMP_FS}" "DUMP_FS"

# build the source password option
if [ -z "${DBPASSWD}" ]; then
   DBPASSWD_OPT=""
else
   DBPASSWD_OPT="-p${DBPASSWD}"
fi

# create timestamp
DATETIME=$(date +"%Y%m%d-%H%M%S")

# filename
DUMP_FILE=${DUMP_FS}/${DATETIME}-db.sql

#
# dump database data
#
echo "Dumping dataset (${DBNAME} @ ${DBHOST})"
${DUMP_TOOL} -h ${DBHOST} -P ${DBPORT} -u ${DBUSER} ${DBPASSWD_OPT} ${DUMP_OPTIONS} ${DBNAME} > ${DUMP_FILE}
exit_on_error $? "Dump dataset failed with error $?"

# compress the files
${COMPRESS_TOOL} ${DUMP_FILE}
exit_on_error $? "Compressing source failed with error $?"

# all over
exit 0

#
# end of file
#
