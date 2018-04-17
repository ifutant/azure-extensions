#!/usr/bin/env bash


set -e
set -u

readonly MASTER_CONFIG='file_roots:,  base:,    - /srv/salt,    - /srv/formulas,    - /srv/salt/roles,pillar_roots:,  base:,    - /srv/pillar,  dev:,    - /srv/pillar/dev,  production:,    - /srv/pillar/production'


function install_salt_repo() {
  rpm --import https://repo.saltstack.com/yum/redhat/7/x86_64/archive/2017.7.1/SALTSTACK-GPG-KEY.pub
  local repofile='/etc/yum.repos.d/saltstack.repo'
  echo '[saltstack-repo]' > $repofile
  echo 'name=SaltStack repo for RHEL/CentOS $releasever' >> $repofile
  echo 'baseurl=https://repo.saltstack.com/yum/redhat/$releasever/$basearch/archive/2017.7.1' >> $repofile
  echo 'enabled=1'  >> $repofile
  echo 'gpgcheck=1' >> $repofile
  echo 'gpgkey=https://repo.saltstack.com/yum/redhat/$releasever/$basearch/archive/2017.7.1/$releaseverSALTSTACK-GPG-KEY.pub' >> $repofile
  yum clean all
}

function install_salt_master() {
  install_salt_repo
  yum update -y
  yum install salt-master salt-minion -y
  echo -e "$MASTER_CONFIG" | tr ',' '\n' > /etc/salt/master
  for service in salt-master salt-minion; do
    systemctl enable $service.service
    systemctl start $service.service
  done
}


function install_salt_minion() {
  local master=$1
  install_salt_repo
  yum install salt-minion -y
  echo "master: $master" > /etc/salt/minion
  systemctl enable salt-minion.service
  systemctl start salt-minion.service
  salt-call saltutil.sync_grains
  salt-call saltutil.refresh_pillar
  salt-call state.highstate
  yum update -y
  salt-call state.highstate
  yum-complete-transaction
  echo "startup_states: highstate" >> /etc/salt/minion
  shutdown -r now
}


main() {
  if [[ $1 == 'master' ]]; then
     install_salt_master
  else
     install_salt_minion $2
  fi
}
main $@
