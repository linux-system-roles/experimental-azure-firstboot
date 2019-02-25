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
LOCAL_LOG_FILE=${LOCAL_LOG_FILE:-/var/log/firstboot/status.log}
#

if [ ! -e /etc/issue.orig ]; then
    cp -p /etc/issue /etc/issue.orig
else
    cp -p /etc/issue.orig /etc/issue
fi

[ ! -d $(dirname $LOCAL_LOG_FILE) ] && mkdir -p $(dirname $LOCAL_LOG_FILE)

{
    echo "Full log can be found in /root/firstboot.log"
    echo "This summary can be found in ${LOCAL_LOG_FILE}";
} > ${LOCAL_LOG_FILE}

if mountpoint "${CONFIG_DIR}"; then
   echo "Configuration Directory is mounted"
else
   mount -L ${CONFIG_LABEL} ${CONFIG_DIR} || echo "Failed to mount Configuration Directory" | tee -a ${LOCAL_LOG_FILE}
fi

[ ! -d ${CONFIG_DIR}/log ] && mkdir -p ${CONFIG_DIR}/log

if [ -f "${CONFIG_FILE}" -a -d ${PB_DIR} ]; then
   errors=()
   pushd ${PB_DIR}
   for p in [0-9][0-9]-*.yml; do
       ansible-playbook ${PB_OPTIONS} $p 2>&1 | tee ${CONFIG_DIR}/log/${p}.log /var/log/firstboot/${p}.log
       ansistatus=${PIPESTATUS[0]}
       if [ ${ansistatus} -gt 0 ]; then
           errors=( "${errors[@]}" "$p $ansistatus ${p}.log" )
       fi
   done
   popd

   if test "$errors"; then
       rm ${CONFIG_DIR}/workload_sucess_is_true
       > ${CONFIG_DIR}/workload_sucess_is_false
       {
           echo "The following setup playbooks terminated with errors."
           echo "Format: <playbook> <ansible exit code> <log file under configLUN/log and /var/log/firstboot>"
           for i in "${errors[@]}"; do
               echo "$i"
           done
           echo ;
       } | tee -a ${LOCAL_LOG_FILE} ${CONFIG_DIR}/workload_sucess_is_false
       rc=1
   else
       > ${CONFIG_DIR}/workload_sucess_is_true
       rm ${CONFIG_DIR}/workload_sucess_is_false
       {
           echo "############################################"
           echo "# Successfully applied all setup playbooks #"
           echo "############################################"
           echo ;
       } | tee -a ${LOCAL_LOG_FILE} ${CONFIG_DIR}/workload_sucess_is_true
       rc=0
   fi
else
    rm ${CONFIG_DIR}/workload_sucess_is_true
    > ${CONFIG_DIR}/workload_sucess_is_false
    echo "No Configuration found" | tee -a /var/log/firstboot/status.log ${CONFIG_DIR}/workload_sucess_is_false
    rc=2
fi

cat /etc/issue.orig /var/log/firstboot/status.log > /etc/issue

umount ${CONFIG_DIR}

exit $rc
