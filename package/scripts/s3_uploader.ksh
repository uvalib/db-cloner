#!/usr/bin/env bash
#
# Upload files from the supplied directory to S3
#

#set -x

# source the common helper
DIR=$(dirname $0)
. $DIR/common.ksh

# ensure the necessary tools exist
AWS_TOOL=aws
ensure_tool_available ${AWS_TOOL}

# validate the environment
ensure_var_defined "${UPLOAD_DIR}" "UPLOAD_DIR"
ensure_var_defined "${TARGET_BUCKET}" "TARGET_BUCKET"
ensure_var_defined "${TARGET_DIR}" "TARGET_DIR"

# create a list of files to upload
FILE_LIST=/tmp/files.$$
ls -p ${UPLOAD_DIR} | grep -v / > ${FILE_LIST}

# go through list of files
for file in $(<${FILE_LIST}); do

   echo -n "Uploading ${file}... "
   ${AWS_TOOL} s3 cp ${UPLOAD_DIR}/${file} s3://${TARGET_BUCKET}/${TARGET_DIR}/${file} --quiet
   exit_on_error $? "uploading ${file} to S3"
   echo "done"
   rm -fr ${UPLOAD_DIR}/${file} > /dev/null 2>&1

done

# cleanup
rm -fr ${FILE_LIST}

# all over
echo "Terminating with status 0"
exit 0

#
# end of file
#
