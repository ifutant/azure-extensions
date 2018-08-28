#!/usr/bin/env bash
PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin

MASTER=$1
POD=$2
REGEX_HOSTNAME="^[a-z]{15}"
hostname | grep -E "${REGEX_HOSTNAME}" > /etc/salt/minion_id
printf "%s\n" "master: $MASTER" "startup_states: highstate" "grains:" "  pod: $POD" "  deployment_method: packer_post_deploy" > /etc/salt/minion 
systemctl enable salt-minion.service
systemctl start salt-minion.service
salt-call saltutil.sync_grains
salt-call saltutil.refresh_pillar
salt-call state.highstate
salt-call state.highstate
exit 0
