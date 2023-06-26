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
ensure_var_defined "${SRC_REMOTE_FS}" "SRC_REMOTE_FS"
ensure_var_defined "${SRC_LOCAL_FS}" "SRC_LOCAL_FS"
ensure_var_defined "${SRC_MOUNT_PARAMS}" "SRC_MOUNT_PARAMS"

# validate the destination environment
ensure_var_defined "${DST_REMOTE_FS}" "DST_REMOTE_FS"
ensure_var_defined "${DST_LOCAL_FS}" "DST_LOCAL_FS"
ensure_var_defined "${DST_MOUNT_PARAMS}" "DST_MOUNT_PARAMS"

# validate other environment needs
ensure_var_defined "${DUMP_FS}" "DUMP_FS"

# bit of sanity checking to prevent operator error
if [ "${SRC_REMOTE_FS}" == "${DST_REMOTE_FS}" ]; then
   error_and_exit "ERROR: source remote filesystem cannot be the same as the destination remote filesystem"
fi
if [ "${SRC_LOCAL_FS}" == "${DST_LOCAL_FS}" ]; then
   error_and_exit "ERROR: source local filesystem cannot be the same as the destination local filesystem"
fi

# create timestamp
DATETIME=$(date +"%Y%m%d-%H%M%S")

# filenames
SRC_ARCHIVE_FILE=${DUMP_FS}/${DATETIME}-src.tgz
DST_ARCHIVE_FILE=${DUMP_FS}/${DATETIME}-dst.tgz

# create local filesystem mount points
mkdir ${SRC_LOCAL_FS}
chmod 777 ${SRC_LOCAL_FS}
mkdir ${DST_LOCAL_FS}
chmod 777 ${DST_LOCAL_FS}

# mount source filesystem
${MOUNT_TOOL} ${SRC_MOUNT_PARAMS} ${SRC_REMOTE_FS} ${SRC_LOCAL_FS}
exit_on_error $? "Mounting source (${SRC_REMOTE_FS}) failed with error $?"

# mount destination filesystem
${MOUNT_TOOL} ${DST_MOUNT_PARAMS} ${DST_REMOTE_FS} ${DST_LOCAL_FS}
exit_on_error $? "Mounting destination (${DST_REMOTE_FS}) failed with error $?"

# do the source archive
echo "Archiving ${SRC_REMOTE_FS} -> ${SRC_ARCHIVE_FILE}"
${ARCHIVE_TOOL} czvf ${SRC_ARCHIVE_FILE} ${SRC_LOCAL_FS}/
exit_on_error $? "Archiving source failed with error $?"

# do the destination archive 
echo "Archiving ${DST_REMOTE_FS} -> ${DST_ARCHIVE_FILE}"
${ARCHIVE_TOOL} czvf ${DST_ARCHIVE_FILE} ${DST_LOCAL_FS}/
exit_on_error $? "Archiving destination failed with error $?"

# unmount the mounted filesystems
${UNMOUNT_TOOL} ${SRC_LOCAL_FS}
${UNMOUNT_TOOL} ${DST_LOCAL_FS}

# all over
echo "Terminating with status 0"
exit 0

#
# end of file
#
