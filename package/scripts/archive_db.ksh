#!/usr/bin/env bash

# source the common helper
DIR=$(dirname $0)
. ${DIR}/common.ksh

# validate the environment
ensure_var_defined "${DBMODE}" "DBMODE"

# define the run script name
RUNNER=${DIR}/${DBMODE}_db_archive.ksh
ensure_file_exists ${RUNNER}

# run the archiver script
${RUNNER}
res=$?

# all over
echo "Terminating with status ${res}"
exit ${res}

#
# end of file
#
