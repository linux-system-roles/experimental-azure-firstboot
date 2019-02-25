#!/bin/bash
#
#####
# This script simply runs given playbooks from a config disk
#
#####
# Add playbook options here (Default -vv for debugging output)
PB_OPTIONS=${PB_OPTIONS:-"-vv"}
CONFIG_LABEL=${CONFIG_LABEL:-azconfig}
CONFIG_DIR=${CONFIG_DIR:-/mnt}
PB_DIR=${PB_DIR:-${CONFIG_DIR}/playbooks}
CONFIG_FILE=${CONFIG_FILE:-${CONFIG_DIR}/azconfig.yml}
#
if awk '{print $2}' /etc/mtab | grep -q "${CONFIG_DIR}"; then
   echo "Configuration Directory is mounted"
else
   mount -L ${CONFIG_LABEL} ${CONFIG_DIR}
fi

[ ! -d ${CONFIG_DIR}/log ] && mkdir -p ${CONFIG_DIR}/log
if [ -f "${CONFIG_FILE}" -a -d ${PB_DIR} ]; then
   pushd ${PB_DIR}
   for p in [0-9][0-9]-*.yml; do
	ansible-playbook ${PB_OPTIONS} $p 2>&1 | tee ${CONFIG_DIR}/log/${p}.log
   done
   popd
   echo "##########################################"
   echo "# Successfully implemented all playbooks #"
   echo "##########################################"
else
   echo "No Configuration found" | tee ${CONFIG_DIR}/log/noconfig.log
fi

umount ${CONFIG_DIR}

