#!/usr/bin/env bash

#set -x

# source the common helper
DIR=$(dirname $0)
. ${DIR}/common.ksh

# ensure the necessary tools exist
MOUNT_TOOL=mount
ensure_tool_available ${MOUNT_TOOL}
UNMOUNT_TOOL=umount
ensure_tool_available ${UNMOUNT_TOOL}
ARCHIVE_TOOL=tar
ensure_tool_available ${ARCHIVE_TOOL}

# validate the source environment
ensure_var_defined "${REMOTE_FS}" "REMOTE_FS"
ensure_var_defined "${LOCAL_FS}" "LOCAL_FS"
ensure_var_defined "${MOUNT_PARAMS}" "MOUNT_PARAMS"

# validate other environment needs
ensure_var_defined "${DUMP_FS}" "DUMP_FS"

# create timestamp
DATETIME=$(date +"%Y%m%d-%H%M%S")

# filenames
ARCHIVE_FILE=${DUMP_FS}/${DATETIME}-fs.tgz

# create local filesystem mount points
mkdir ${LOCAL_FS}
chmod 777 ${LOCAL_FS}

# mount source filesystem
${MOUNT_TOOL} ${MOUNT_PARAMS} ${REMOTE_FS} ${LOCAL_FS}
exit_on_error $? "Mounting source (${REMOTE_FS}) failed with error $?"

# do the archive
echo "Archiving ${REMOTE_FS} -> ${ARCHIVE_FILE}"
${ARCHIVE_TOOL} czvf ${ARCHIVE_FILE} ${LOCAL_FS}/
exit_on_error $? "Archiving filesystem failed with error $?"

# unmount the mounted filesystem
${UNMOUNT_TOOL} ${LOCAL_FS}

# all over
echo "Terminating with status 0"
exit 0

#
# end of file
#
