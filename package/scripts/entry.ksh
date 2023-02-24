#!/usr/bin/env bash

# source the common helper
DIR=$(dirname $0)
. ${DIR}/common.ksh

# validate the environment
ensure_var_defined "${DBMODE}" "DBMODE"

# define the run script name
RUNNER=${DIR}/${DBMODE}_db_clone.ksh
ensure_file_exists ${RUNNER}

# run the cloner script
${RUNNER}

# all over
exit $?

#
# end of file
#
