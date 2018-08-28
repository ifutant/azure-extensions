#!/usr/bin/env bash
PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin

REGEX_HOSTNAME="^[a-z]{15}"

hostname | grep -E "${REGEX_HOSTNAME}" > /etc/salt/minion_id
salt-call state.highstate -l debug --local
salt-call state.highstate -l debug --local
salt-call system.reboot 1
exit 0
