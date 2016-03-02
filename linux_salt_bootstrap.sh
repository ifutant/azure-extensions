#!/usr/bin/env bash


set -e
set -u

readonly MASTER_CONFIG='file_roots:,  base:,    - /srv/salt,    - /srv/formulas,    - /srv/salt/roles,pillar_roots:,  base:,    - /srv/pillar,  dev:,    - /srv/pillar/dev,  production:,    - /srv/pillar/production'

function install_centos_repo() {
  rm -f /etc/yum.repos.d/CentOS-* /etc/yum.repos.d/OpenLogic.repo
  echo '[base]' > /etc/yum.repos.d/Centos-Base.repo
  echo 'name=CentOS-$releasever - Base' >> /etc/yum.repos.d/Centos-Base.repo
  echo 'mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os' >> /etc/yum.repos.d/Centos-Base.repo
  echo 'gpgcheck=1' >> /etc/yum.repos.d/Centos-Base.repo
  echo 'gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7' >> /etc/yum.repos.d/Centos-Base.repo
  echo 'protect=1' >> /etc/yum.repos.d/Centos-Base.repo
  yum clean all
}


function install_salt_repo() {
  rpm --import https://repo.saltstack.com/yum/redhat/7/x86_64/latest/SALTSTACK-GPG-KEY.pub
  local repofile='/etc/yum.repos.d/saltstack.repo'
  echo '[saltstack-repo]' > $repofile
  echo 'name=SaltStack repo for RHEL/CentOS $releasever' >> $repofile
  echo 'baseurl=https://repo.saltstack.com/yum/redhat/$releasever/$basearch/latest' >> $repofile
  echo 'enabled=1'  >> $repofile
  echo 'gpgcheck=1' >> $repofile
  echo 'gpgkey=https://repo.saltstack.com/yum/redhat/$releasever/$basearch/latest/$releaseverSALTSTACK-GPG-KEY.pub' >> $repofile
  yum clean all
}


function install_salt_master() {
  install_salt_repo
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
}


main() {
  install_centos_repo
  if [[ $1 == 'master' ]]; then
     install_salt_master
  else
     install_salt_minion $2
  fi
}
main $@
