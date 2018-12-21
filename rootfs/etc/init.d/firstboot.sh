#!/bin/bash
#
#####
# This script simply runs given playbooks in /etc/firstboot.d
#
#####
# Add playbook options here (Default -vv for debugging output)
PB_OPTIONS="-vv"
#
pushd /etc/firstboot.d
for p in *.yml
	ansible-playbook ${PB_OPTIONS} $p || exit 1
done
popd

echo "##########################################"
echo "# Successfully implemented all playbooks #"
echo "##########################################"
