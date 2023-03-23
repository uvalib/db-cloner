#!/usr/bin/env bash

#set -x

# source the common helper
DIR=$(dirname $0)
. ${DIR}/common.ksh

# ensure the necessary tools exist
SUDO_TOOL=sudo
ensure_tool_available ${SUDO_TOOL}
MOUNT_TOOL=mount
ensure_tool_available ${MOUNT_TOOL}
UNMOUNT_TOOL=umount
ensure_tool_available ${UNMOUNT_TOOL}
SYNC_TOOL=rsync
ensure_tool_available ${SYNC_TOOL}

# validate the source environment
ensure_var_defined "${SRC_REMOTE_FS}" "SRC_REMOTE_FS"
ensure_var_defined "${SRC_LOCAL_FS}" "SRC_LOCAL_FS"
ensure_var_defined "${SRC_MOUNT_PARAMS}" "SRC_MOUNT_PARAMS"

# validate the destination environment
ensure_var_defined "${DST_REMOTE_FS}" "DST_REMOTE_FS"
ensure_var_defined "${DST_LOCAL_FS}" "DST_LOCAL_FS"
ensure_var_defined "${DST_MOUNT_PARAMS}" "DST_MOUNT_PARAMS"

# bit of sanity checking to prevent operator error
if [ "${SRC_REMOTE_FS}" == "${DST_REMOTE_FS}" ]; then
   error_and_exit "ERROR: source remote filesystem cannot be the same as the destination remote filesystem"
fi
if [ "${SRC_LOCAL_FS}" == "${DST_LOCAL_FS}" ]; then
   error_and_exit "ERROR: source local filesystem cannot be the same as the destination local filesystem"
fi

# create local filesystem mount points
${SUDO_TOOL} mkdir ${SRC_LOCAL_FS}
${SUDO_TOOL} chmod 777 ${SRC_LOCAL_FS}
${SUDO_TOOL} mkdir ${DST_LOCAL_FS}
${SUDO_TOOL} chmod 777 ${DST_LOCAL_FS}

# mount source filesystem
${SUDO_TOOL} ${MOUNT_TOOL} ${SRC_MOUNT_PARAMS} ${SRC_REMOTE_FS} ${SRC_LOCAL_FS}
exit_on_error $? "Mounting source (${SRC_REMOTE_FS}) failed with error $?"

# mount destination filesystem
${SUDO_TOOL} ${MOUNT_TOOL} ${DST_MOUNT_PARAMS} ${DST_REMOTE_FS} ${DST_LOCAL_FS}
exit_on_error $? "Mounting destination (${DST_REMOTE_FS}) failed with error $?"

# do the sync
echo "Syncing ${SRC_REMOTE_FS} -> ${DST_REMOTE_FS}"
${SYNC_TOOL} ${SYNC_OPTIONS:--archive} ${SRC_LOCAL_FS}/ ${DST_LOCAL_FS}/
res=$?
if [ ${res} -eq 23 ]; then
   echo "WARNING: ignoring error ${res}"
   res=0
fi
exit_on_error ${res} "Syncing failed with error $?"

# unmount the mounted filesystems
${SUDO_TOOL} ${UNMOUNT_TOOL} ${SRC_LOCAL_FS}
${SUDO_TOOL} ${UNMOUNT_TOOL} ${DST_LOCAL_FS}

# all over
echo "Terminating with status 0"
exit 0

#
# end of file
#
