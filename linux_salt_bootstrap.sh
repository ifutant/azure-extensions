#!/usr/bin/env bash


set -e
set -u

readonly JENKINS_KEY='ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAul/y76FjXXnLG1pT817S2pJFNV6sTw9JBKYSuPQINv34jR2V6Ad8Lnjg+7IKIdkG6y71NNnNxIXzR9eAaBPdkxb+0kQ0eul/8KBe8xHxQjDZvPsU5yEjnQh/2QqZsdNd+AqQVAe+Uj1RyYp1KuWAUlSlw60SVvDr8lR3anxYgMdrQm7esBxCVMSgvpvdbyYY0fk/h1oE3SyqZBM1VAksNEEQfSfgAVZXyHCJ8RsGpnQHJiOZaBDIo+qAO7CXxXJxqbGzQwFRSNfHCx/krIn4Fvls6UljY0+peAHZposApqrK4Fb/0PKcxUf7FBHbHphjY6CD5Hg6RdUpSuEZDzikow== jenkins@ndmops-vljen000.hce.escriptioncolo.com'

readonly MASTER_CONFIG='file_roots:,  base:,    - /srv/salt,    - /srv/formulas,    - /srv/salt/roles,pillar_roots:,  base:,    - /srv/pillar,  dev:,    - /srv/pillar/dev,  prod:,    - /srv/pillar/prod'


function pre_install() {
  yum update -y
  yum install rsync -y
}

function configure_jenkins() {
  useradd jenkins
  mkdir -p $HOME/jenkins/.ssh
  chmod 700 $HOME/jenkins/.ssh
  echo $JENKINS_KEY > $HOME/jenkins/.ssh/authorized_keys
  chmod 600 $HOME/jenkins/.ssh/authorized_keys
  echo 'jenkins ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
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
  configure_jenkins
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
  if [[ $1 == 'master' ]]; then
     install_salt_master
  else
     install_salt_minion $2
  fi
}
main $@
