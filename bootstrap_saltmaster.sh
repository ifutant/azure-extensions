#!/bin/bash

curl -ks http://bootstrap.saltstack.com/stable/bootstrap-salt.sh | sh
yum install salt-master -y
systemctl start salt-master
