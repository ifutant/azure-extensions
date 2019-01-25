#!/usr/bin/env bash
PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin
SALTDIRECTORY=/deployTemp
REGEX_HOSTNAME="^[a-z]{15}"

hostname | grep -E "${REGEX_HOSTNAME}" > /etc/salt/minion_id
if [ -d "$SALTDIRECTORY" ]; then
salt-call file.replace '/etc/salt/minion' pattern='packer_pre_deploy' repl='packer_post_deploy'
salt-call state.highstate -l debug --local
salt-call state.highstate -l debug --local
salt-call system.reboot 5
rm -rf $SALTDIRECTORY
systemctl disable salt-minion
fi
exit 0
